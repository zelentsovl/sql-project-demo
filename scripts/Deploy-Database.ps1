[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory)]
    [string] $Location,

    [Parameter(Mandatory)]
    [string] $AdministratorLogin,

    [Parameter(Mandatory)]
    [guid] $AdministratorObjectId,

    [ValidateSet('Application', 'Group', 'User')]
    [string] $AdministratorPrincipalType = 'Application',

    [ValidateSet('development', 'production')]
    [string] $EnvironmentName = 'development',

    [hashtable] $ResourceGroupTags = @{},

    [switch] $SkipSmokeTest
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$parameterFile = Join-Path $repositoryRoot "infra/environments/$EnvironmentName.bicepparam"
$projectFile = Join-Path $repositoryRoot 'azuredbsqlproj/azuredbsqlproj.sqlproj'
$dacpacFile = Join-Path $repositoryRoot 'azuredbsqlproj/bin/Release/azuredbsqlproj.dacpac'
$smokeTestFile = Join-Path $repositoryRoot 'tests/SmokeTest.sql'
$deploymentName = "integrated-resort-$EnvironmentName-$(Get-Date -Format 'yyyyMMddHHmmss')"
$firewallRuleName = "local-$([guid]::NewGuid().ToString('N').Substring(0, 12))"

foreach ($commandName in 'az', 'dotnet') {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "Required command '$commandName' was not found on PATH."
    }
}

az account show --output none
dotnet build $projectFile --configuration Release

if (-not (Get-Command sqlpackage -ErrorAction SilentlyContinue)) {
    dotnet tool install --global Microsoft.SqlPackage
    $env:PATH = "$env:PATH;$HOME/.dotnet/tools"
}

if (-not $PSCmdlet.ShouldProcess($ResourceGroupName, "Deploy $EnvironmentName Azure SQL infrastructure and database")) {
    return
}

$groupCreateArgs = @('group', 'create', '--name', $ResourceGroupName, '--location', $Location, '--output', 'none')
if ($ResourceGroupTags.Count -gt 0) {
    $groupCreateArgs += '--tags'
    $groupCreateArgs += ($ResourceGroupTags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" })
}
az @groupCreateArgs
az deployment group validate `
    --resource-group $ResourceGroupName `
    --parameters $parameterFile `
    --parameters administratorLogin=$AdministratorLogin `
                 administratorObjectId=$AdministratorObjectId `
                 administratorPrincipalType=$AdministratorPrincipalType `
    --output none

$outputs = az deployment group create `
    --name $deploymentName `
    --resource-group $ResourceGroupName `
    --parameters $parameterFile `
    --parameters administratorLogin=$AdministratorLogin `
                 administratorObjectId=$AdministratorObjectId `
                 administratorPrincipalType=$AdministratorPrincipalType `
    --query properties.outputs `
    --output json | ConvertFrom-Json

$sqlServerName = $outputs.sqlServerName.value
$sqlServerFqdn = $outputs.sqlServerFullyQualifiedDomainName.value
$databaseName = $outputs.databaseName.value
$runnerIp = (Invoke-RestMethod -Uri 'https://api.ipify.org').Trim()

try {
    az sql server firewall-rule create `
        --resource-group $ResourceGroupName `
        --server $sqlServerName `
        --name $firewallRuleName `
        --start-ip-address $runnerIp `
        --end-ip-address $runnerIp `
        --output none

    $accessToken = az account get-access-token `
        --resource 'https://database.windows.net/' `
        --query accessToken `
        --output tsv

    sqlpackage `
        /Action:Publish `
        /SourceFile:$dacpacFile `
        /TargetServerName:$sqlServerFqdn `
        /TargetDatabaseName:$databaseName `
        /AccessToken:$accessToken `
        /p:BlockOnPossibleDataLoss=True `
        /p:DropObjectsNotInSource=False `
        /v:EnvironmentName=$EnvironmentName `
        /v:SeedDemoData=$($EnvironmentName -eq 'development')

    if (-not $SkipSmokeTest) {
        if (-not (Get-Module SqlServer -ListAvailable)) {
            Install-Module SqlServer -Scope CurrentUser -Force -AllowClobber
        }

        Invoke-Sqlcmd `
            -ServerInstance $sqlServerFqdn `
            -Database $databaseName `
            -AccessToken $accessToken `
            -InputFile $smokeTestFile `
            -AbortOnError
    }
}
finally {
    az sql server firewall-rule delete `
        --resource-group $ResourceGroupName `
        --server $sqlServerName `
        --name $firewallRuleName `
        --output none 2>$null
}

Write-Host "Deployed $databaseName to $sqlServerFqdn."
