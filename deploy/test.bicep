targetScope = 'subscription'

var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
param environment string = 'preview'
var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup
}

module postgresServer 'modules/postgresql.bicep' = {
  name: 'DeployPostgresql'
  scope: resourceGroup
  params: {
    location: 'germanywestcentral'
    administratorLogin: 'cmsadmin'
    administratorLoginPassword: keyVault.getSecret('POSTGRES-ADMIN-PASSWORD')
    resourceName: 'pgsql-xprtzbv-cms-bicep'
  }
}

// module postgresCreateUserAndSchema 'modules/postgres-user-schema.bicep' = {
//   name: 'DeployPostgresqlUserAndSchema'
//   scope: resourceGroup
//   params: {
//     location: 'germanywestcentral'
//     administratorLogin: 'cmsadmin'
//     administratorLoginPassword: keyVault.getSecret('POSTGRES-ADMIN-PASSWORD')
//     customUserName: 'strapi_user'
//     customUserPassword:keyVault.getSecret('POSTGRES-STRAPI-PASSWORD')
//     databaseName: 'strapi'
//     databaseSchema: 'strapi'
//     serverName: 'pgsql-xprtzbv-cms-bicep'
//   }
// }
