targetScope = 'subscription'

param location string = 'westeurope'
param imageTag string = 'latest'

var defaultWebsiteName = 'xprtzbv-website'
var defaultCmsName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultWebsiteName}'
var appIdentityName = 'id-${defaultWebsiteName}'
var frontDoorEndpointName = 'fde-${defaultCmsName}'
var keyVaultName = 'kv-${defaultCmsName}'
var postgreSqlName = 'psql-${defaultCmsName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource appIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: appIdentityName
}

module keyVault 'modules/key-vault.bicep' = {
  scope: resourceGroup
  name: 'Deploy-KeyVault-Cms'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityPrincipalIds: [ appIdentity.properties.principalId ]
  }
}

module appService 'modules/app-service.bicep' = {
  scope: resourceGroup
  name: 'Deploy-AppService-Cms'
  params: {
    defaultName: defaultCmsName
    keyvaultName: keyVault.outputs.keyVaultName
    location: location
    appIdentityId: appIdentity.id
    postgresDbUri: postgreSQL.outputs.databaseUri
  }
}

// module containerAppCms 'modules/container-app-cms.bicep' = {
//   scope: resourceGroup
//   name: 'Deploy-Container-App-Cms'
//   params: {
//     // location: location
//     keyVaultName: keyVaultName
//     containerAppUserAssignedIdentityResourceId: appIdentity.id
//     containerAppUserAssignedIdentityClientId: appIdentity.properties.clientId
//     imageTag: imageTag
//     postgresDbUri: postgreSQL.outputs.databaseUri
//   }
// }

module frontDoor 'modules/front-door.bicep' = if (imageTag == 'latest') {
  scope: resourceGroup
  name: 'Deploy-Front-Door'
  params: {
    frontDoorEndpointName: frontDoorEndpointName
    originHostname: appService.outputs.appUrl
  }
}

module postgreSQL 'modules/postgresql.bicep' = {
  scope: resourceGroup
  name: 'Deploy-PostgreSQL'
  params: {
    resourceName: postgreSqlName
    location: 'germanywestcentral'
    cmsUami: appIdentity.properties.principalId
    cmsUamiName: appIdentity.name
  }
}
