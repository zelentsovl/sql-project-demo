using '../main.bicep'

param environmentName = 'development'
param administratorLogin = 'replace-with-ci-principal-name'
param administratorObjectId = '00000000-0000-0000-0000-000000000000'
param databaseSkuName = 'GP_S_Gen5_1'
param databaseSkuTier = 'GeneralPurpose'
param databaseSkuFamily = 'Gen5'
param databaseSkuCapacity = 1
param autoPauseDelay = 60
param databaseMinCapacity = '0.5'
param publicNetworkAccess = 'Enabled'
