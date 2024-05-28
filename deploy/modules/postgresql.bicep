param resourceName string
param location string
param cmsUami string

resource postgreSql 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: resourceName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    createMode: 'Default'
    storage: {
      storageSizeGB: 32
      type: 'PremiumV2_LRS'
      iops: 3000
      throughput: 125
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
