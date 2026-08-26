targetScope = 'resourceGroup'

metadata name = 'Integrated Resort Azure SQL'
metadata description = 'Deploys an Entra-only Azure SQL logical server, database, and monitoring for the integrated resort sample.'

@description('Deployment environment name used in resource names and tags.')
@allowed([
  'development'
  'test'
  'production'
])
param environmentName string = 'development'

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Globally unique Azure SQL logical server name.')
@minLength(1)
@maxLength(63)
param sqlServerName string = take('sql-integratedresort-${environmentName}-${uniqueString(subscription().subscriptionId, resourceGroup().id)}', 63)

@description('Azure SQL database name.')
@minLength(1)
param databaseName string = 'IntegratedResort'

@description('Display name of the Microsoft Entra principal that deploys the DACPAC.')
@minLength(1)
param administratorLogin string

@description('Object ID of the Microsoft Entra principal that deploys the DACPAC. This is not the application client ID.')
param administratorObjectId string

@description('Microsoft Entra principal type for the database administrator.')
@allowed([
  'Application'
  'Group'
  'User'
])
param administratorPrincipalType string = 'Application'

@description('Azure SQL database SKU name.')
param databaseSkuName string = 'GP_S_Gen5_1'

@description('Azure SQL database SKU tier.')
param databaseSkuTier string = 'GeneralPurpose'

@description('Azure SQL database SKU family.')
param databaseSkuFamily string = 'Gen5'

@description('Azure SQL database SKU capacity.')
@minValue(1)
param databaseSkuCapacity int = 1

@description('Minutes of inactivity before a serverless database pauses. Use -1 to disable auto-pause.')
param autoPauseDelay int = 60

@description('Minimum serverless vCore capacity.')
param databaseMinCapacity string = '0.5'

@description('Whether public network connectivity is enabled. Use Disabled with a private endpoint and self-hosted deployment agent in production.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional tags merged with the standard workload tags.')
param additionalTags object = {}

var tags = union({
  application: 'integrated-resort'
  environment: environmentName
  dataClassification: 'synthetic-demo'
  managedBy: 'bicep'
}, additionalTags)

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.16.0' = {
  params: {
    name: take('log-integratedresort-${environmentName}-${uniqueString(resourceGroup().id)}', 63)
    location: location
    dailyQuotaGb: '1'
    dataRetention: 30
    tags: tags
  }
}

module sqlServer 'br/public:avm/res/sql/server:0.22.0' = {
  params: {
    name: sqlServerName
    location: location
    administrators: {
      azureADOnlyAuthentication: true
      login: administratorLogin
      principalType: administratorPrincipalType
      sid: administratorObjectId
      tenantId: tenant().tenantId
    }
    auditSettings: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
    databases: [
      {
        autoPauseDelay: autoPauseDelay
        availabilityZone: -1
        backupShortTermRetentionPolicy: {
          diffBackupIntervalInHours: 24
          retentionDays: 7
        }
        diagnosticSettings: [
          {
            logCategoriesAndGroups: [
              {
                categoryGroup: 'allLogs'
              }
            ]
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            workspaceResourceId: logAnalytics.outputs.resourceId
          }
        ]
        maxSizeBytes: 34359738368
        minCapacity: databaseMinCapacity
        name: databaseName
        requestedBackupStorageRedundancy: 'Local'
        sku: {
          capacity: databaseSkuCapacity
          family: databaseSkuFamily
          name: databaseSkuName
          tier: databaseSkuTier
        }
        zoneRedundant: false
      }
    ]
    managedIdentities: {
      systemAssigned: true
    }
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: 'Enabled'
    tags: tags
  }
}

output databaseName string = databaseName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.resourceId
output sqlServerFullyQualifiedDomainName string = sqlServer.outputs.fullyQualifiedDomainName
output sqlServerName string = sqlServer.outputs.name
