targetScope = 'subscription'

param location string = 'germanywestcentral'
param environment string = 'preview'
param imageTag string = 'latest'

var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var containerAppIdentityName = 'id-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

module containerAppCms 'modules/container-app-cms.bicep' = if (environment == 'preview') {
  scope: resourceGroup
  name: 'Deploy-Container-App-Cms'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    imageTag: imageTag
  }
}

output cmsFqdn string = containerAppCms.outputs.containerAppUrl
