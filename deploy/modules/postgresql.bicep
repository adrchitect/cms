param resourceName string
// param location string
param cmsUami string

resource postgreSql 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: resourceName
  location: 'eastus'
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    createMode: 'Default'
    version: '16'
    storage: {
      storageSizeGB: 32
      type: 'PremiumV2_LRS'
      iops: 3000
      throughput: 125
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
    }
  }

  resource administrators 'administrators' = {
    name: cmsUami
    properties: {
      tenantId: tenant().tenantId
      principalType: 'ServicePrincipal'
    }
  }
}

output databaseUri string = '${postgreSql.name}.postgres.database.azure.com'
