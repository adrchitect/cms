param frontDoorEndpointHostName string
param cnameRecordName string
param cnameValidation string

var dnsZoneName = 'xprtz.dev'

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: dnsZoneName
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2023-07-01-preview' = {
  parent: dnsZone
  name: cnameRecordName
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: frontDoorEndpointHostName
    }
  }
}

resource validationTxtRecordForCname 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  parent: dnsZone
  name: '_dnsauth.${cnameRecordName}'
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          cnameValidation
        ]
      }
    ]
  }
}
