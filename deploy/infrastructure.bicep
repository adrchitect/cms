targetScope = 'subscription'

param location string = 'westeurope'
param environment string = 'preview'

var sharedValues = json(loadTextContent('shared-values.json'))
var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var subscriptionId = sharedValues.subscriptionIds.common
var acrResourceGroupName = sharedValues.resources.acr.resourceGroupName
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module logAnalyticsWorkspace 'modules/monitoring.bicep' = {
  scope: resourceGroup
  name: 'Deploy-LogAnalyticsWorkspace'
  params: {
    location: location
    defaultName: defaultName
  }
}

module userManagedIdentity 'modules/user-managed-identity.bicep' = {
  scope: resourceGroup
  name: 'Deploy-UserManagedIdentity'
  params: {
    location: location
  }
}

module acrAndRoleAssignment 'modules/roleassignments.bicep' = {
  scope: az.resourceGroup(subscriptionId, acrResourceGroupName)
  name: 'Deploy-PullRoleAssignment'
  params: {
    principalId: userManagedIdentity.outputs.containerAppIdentityPrincipalId
    acrName: sharedValues.resources.acr.name
  }
}

module keyVault 'modules/key-vault.bicep' = {
  scope: resourceGroup
  name: 'Deploy-KeyVault'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityPrincipalIds: [userManagedIdentity.outputs.containerAppIdentityPrincipalId]
  }
}

module containerAppEnvironment 'modules/container-app-environment.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Environment'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceName
  }
}
