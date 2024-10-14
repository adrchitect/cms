param location string
param keyVaultName string
param containerAppUserAssignedIdentityResourceId string
param containerAppUserAssignedIdentityClientId string
param imageTag string = 'latest'

var name = take('ctap-xprtzbv-cms-${imageTag}', 32)
var dbName = take('psql-xprtzbv-cms-${imageTag}', 32)
var acrServer = 'xprtzbv.azurecr.io'
var imageName = '${acrServer}/cms:${imageTag}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' existing = {
  name: 'me-xprtzbv-cms'
}

resource postgres 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: dbName
  location: location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      service: {
        type: 'postgres'
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-08-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerAppUserAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      registries: [
        {
          server: acrServer
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
      ingress: {
        external: true
        targetPort: 80
      }
      secrets: [
        {
          name: toLower('REF-APP-KEYS')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/APP-KEYS')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-API-TOKEN-SALT')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/API-TOKEN-SALT')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-ADMIN-JWT-SECRET')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/ADMIN-JWT-SECRET')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-TRANSFER-TOKEN-SALT')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/TRANSFER-TOKEN-SALT')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-JWT-SECRET')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/JWT-SECRET')
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
    }
    template: {
      serviceBinds: [
        {
          serviceId: postgres.id
        }
      ]
      containers: [
        {
          name: name
          image: imageName
          resources: {
            cpu: 1
            memory: '2Gi'
          }
          env: [
            {
              name: 'AZURE_CLIENT_ID'
              value: containerAppUserAssignedIdentityClientId
            }
            {
              name: 'NODE_ENV'
              value: 'production'
            }
            {
              name: 'PORT'
              value: '1337'
            }
            {
              name: 'APP_KEYS'
              secretRef: toLower('REF-APP-KEYS')
            }
            {
              name: 'API_TOKEN_SALT'
              secretRef: toLower('REF-API-TOKEN-SALT')
            }
            {
              name: 'ADMIN_JWT_SECRET'
              secretRef: toLower('REF-ADMIN-JWT-SECRET')
            }
            {
              name: 'TRANSFER_TOKEN_SALT'
              secretRef: toLower('REF-TRANSFER-TOKEN-SALT')
            }
            {
              name: 'JWT_SECRET'
              secretRef: toLower('REF-JWT-SECRET')
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output containerAppUrl string = containerApp.properties.latestRevisionFqdn
