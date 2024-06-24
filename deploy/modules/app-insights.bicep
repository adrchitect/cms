param defaultName string
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: 'law-${defaultName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${defaultName}'
  location: location
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${defaultName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logWorkspace.id
  }
}
