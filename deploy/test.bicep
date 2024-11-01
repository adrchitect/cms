targetScope = 'subscription'

param location string = 'germanywestcentral'
param environment string = 'preview'
param imageTag string = 'latest'

var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var environmentShort = environment == 'preview' ? 'prv' : 'prd'


resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

module storage 'modules/storageaccount.bicep' = {
  name: 'Deploy-Storage-Account'
  scope: resourceGroup
  params: {
    app: 'cms'
    environmentShort: environmentShort
  }
}
