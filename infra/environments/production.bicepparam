using '../main.bicep'

param environmentName = 'production'
param administratorLogin = 'replace-with-ci-principal-name'
param administratorObjectId = '00000000-0000-0000-0000-000000000000'
param databaseSkuName = 'GP_Gen5_2'
param databaseSkuTier = 'GeneralPurpose'
param databaseSkuFamily = 'Gen5'
param databaseSkuCapacity = 2
param autoPauseDelay = -1
param databaseMinCapacity = '0'
param publicNetworkAccess = 'Disabled'
param additionalTags = {
  criticality: 'business'
}
