targetScope = 'subscription'

param location string = 'germanywestcentral'
param environment string = 'preview'

var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'
var administratorLogin = 'cmsAdmin'
var databaseServerName = 'pgsql-xprtzbv-cms-${environmentShort}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource keyVaultRef 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup
}

module postgresServer 'modules/postgresql.bicep' = if(environment == 'production') {
  name: 'Deploy-Postgresql'
  scope: resourceGroup
  params: {
    location: location
    administratorLogin: administratorLogin
    administratorLoginPassword: keyVaultRef.getSecret('POSTGRES-ADMIN-PASSWORD')
    databaseServerName: databaseServerName
  }
}

