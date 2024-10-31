targetScope = 'subscription'

param location string = 'germanywestcentral'
param environment string = 'preview'
param imageTag string = 'latest'

var sharedValues = json(loadTextContent('shared-values.json'))
var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var containerAppIdentityName = 'id-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'
var databaseServerName = 'pgsql-xprtzbv-cms-${environmentShort}'
var managementResourceGroup = az.resourceGroup(
  sharedValues.subscriptionIds.common,
  sharedValues.resourceGroups.management
)
var infrastructureResourceGroup = az.resourceGroup(
  sharedValues.subscriptionIds.common,
  sharedValues.resourceGroups.infrastructure
)
var rootDomain = 'xprtz.dev'
var frontDoorProfileName = 'afd-xprtzbv-websites'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

module containerAppCmsProd 'modules/container-app-cms-prod.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Cms-Prod'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    databaseServerName: databaseServerName
    imageTag: imageTag
  }
}

module frontdoorSettings 'modules/frontdoor.bicep' = {
  scope: infrastructureResourceGroup
  name: 'Deploy-Frontdoor-Settings'
  params: {
    frontDoorOriginHost: containerAppCmsProd.outputs.containerAppUrl
    frontDoorProfileName: frontDoorProfileName
    application: 'cms'
    rootDomain: rootDomain
    subDomain: 'cms'
  }
}

module dns 'modules/dns.bicep' = {
  scope: managementResourceGroup
  name: 'Deploy-Dns'
  params: {
    origin: frontdoorSettings.outputs.frontDoorCustomDomainHost
    rootDomain: rootDomain
    subDomain: 'cms'
    validationToken: frontdoorSettings.outputs.frontDoorCustomDomainValidationToken
  }
}
