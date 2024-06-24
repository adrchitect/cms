targetScope = 'subscription'

param location string = 'westeurope'

var sharedValues = json(loadTextContent('shared-values.json'))
var subscriptionId = sharedValues.subscriptionIds.common
var acrResourceGroupName = sharedValues.resources.acr.resourceGroupName
var defaultCmsName = 'xprtzbv-cms'
var resourceGroupName = 'rg-xprtzbv-website'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
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

module appServicePlan 'modules/app-service-plan.bicep' = {
  scope: resourceGroup
  name: 'Deploy-AppServicePlan'
  params: {
    defaultName: defaultCmsName
    location: location
  }
}

module appInsights 'modules/app-insights.bicep' = {
  scope: resourceGroup
  name: 'Deploy-AppInsights'
  params: {
    defaultName: defaultCmsName
    location: location

  }
}

// module containerAppEnvironment 'modules/container-app-environment.bicep' = {
//   scope: resourceGroup
//   name: 'Deploy-Container-App-Environment'
//   params: {
//     location: location
//     logAnalyticsWorkspaceName: appInsights.outputs.logAnalyticsWorkspaceName
//     subnetId: vnet.outputs.subnetId
//   }
// }

module frontDoor 'modules/front-door-profile.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Front-Door-Profile'
  params: {
    frontDoorSkuName: 'Standard_AzureFrontDoor'
    logAnalyticsWorkspaceName: appInsights.outputs.logAnalyticsWorkspaceName
  }
}
