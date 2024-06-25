param defaultName string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'asp-${defaultName}'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}
