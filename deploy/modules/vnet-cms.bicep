// param location string

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-xprtzbv-cms'
  location: 'germanywestcentral'
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    subnets: [
      {
        name: 'sn1'
        properties:{
          addressPrefix: '10.0.0.0/22'
        }
      } 
    ]
  }
}

output name string = vnet.name
output subnetId string = vnet.properties.subnets[0].id
