targetScope = 'subscription'

param alternateLocation string = 'germanywestcentral'
param environment string = 'preview'

var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'
var administratorLogin = 'cmsadmin'
var databaseServerName = 'pgsql-xprtzbv-cms-${environmentShort}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource keyVaultRef 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup
}

module postgresServer 'modules/postgresql.bicep' = {
  name: 'Deploy-Postgresql'
  scope: resourceGroup
  params: {
    location: alternateLocation
    administratorLogin: administratorLogin
    administratorLoginPassword: keyVaultRef.getSecret('POSTGRES-ADMIN-PASSWORD')
    databaseServerName: databaseServerName
  }
}
