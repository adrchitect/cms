param location string
param keyVaultName string
param containerAppUserAssignedIdentityResourceId string
param containerAppUserAssignedIdentityClientId string
param databaseServerName string
param imageTag string = 'latest'
param deployTime int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
param app string = 'cms'
param environment string = 'preview'

var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var name = take('ctap-xprtzbv-cms-${imageTag}', 32)
var acrServer = 'xprtzbv.azurecr.io'
var imageName = '${acrServer}/cms:${imageTag}'
var initImageName = '${acrServer}/cms/init:${imageTag}'
var administratorLogin = 'cmsadmin'
var deployTimeInSecondsSinceEpoch = string(deployTime)
var storageAccountName = take('stxprtzbv${app}${environmentShort}${uniqueString(az.resourceGroup().id)}', 24)


resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' existing = {
  name: 'me-xprtzbv-cms'
}

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' existing = {
  name: databaseServerName
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      days: 7
      enabled: true
    }
  }
}

resource uploadFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  name: 'upload'
  parent: fileServices
  properties: {
    accessTier: 'Hot'
    enabledProtocols: 'SMB'
    shareQuota: 102400
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
        targetPort: 1337
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
        {
          name: toLower('POSTGRES-ADMIN-PASSWORD')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/POSTGRES-ADMIN-PASSWORD')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('POSTGRES-STRAPI-PASSWORD')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/POSTGRES-STRAPI-PASSWORD')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-AZURE-ACS-ENDPOINT')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/AZURE-ACS-ENDPOINT')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-AZURE-ACS-FALLBACK-EMAIL')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/AZURE-ACS-FALLBACK-EMAIL')
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
    }
    template: {
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
              name: 'DEPLOY_TIME_IN_SECONDS_SINCE_EPOCH'
              value: deployTimeInSecondsSinceEpoch
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
            {
              name: 'DATABASE_HOST'
              value: postgres.properties.fullyQualifiedDomainName
            }
            {
              name: 'DATABASE_PORT'
              value: '5432'
            }
            {
              name: 'DATABASE_SSL'
              value: 'true'
            }
            {
              name: 'DATABASE_SCHEMA'
              value: 'strapi'
            }
            {
              name: 'DATABASE_USERNAME'
              value: 'strapi'
            }
            {
              name: 'DATABASE_NAME'
              value: 'strapi'
            }
            {
              name: 'DATABASE_PASSWORD'
              secretRef: toLower('POSTGRES-STRAPI-PASSWORD')
            }
            {
              name: 'AZURE_ENDPOINT'
              secretRef: toLower('REF-AZURE-ACS-ENDPOINT')
            }
            {
              name: 'FALLBACK_EMAIL'
              secretRef: toLower('REF-AZURE-ACS-FALLBACK-EMAIL')
            }
            {
              name: 'STORAGE_AUTH_TYPE'
              value: 'msi'
            }
            {
              name: 'STORAGE_AZURE_CLIENT_ID'
              value: containerAppUserAssignedIdentityClientId
            }
            {
              name: 'STORAGE_ACCOUNT'
              value: storageAccountName
            }
            {
              name: 'STORAGE_CREATE_CONTAINER_IF_NOT_EXIST'
              value: 'true'
            }
            {
              name: 'STORAGE_CONTAINER_NAME'
              value: 'media'
            }
            {
              name: 'STORAGE_PUBLIC_ACCESS_TYPE'
              value: 'container'
            }
          ]
          volumeMounts: [
            {
              mountPath: '/opt/app/public/uploads'
              volumeName: 'upload'
            }
          ]
        }
      ]
      initContainers: [
        {
          name: 'database-init'
          image: initImageName
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'ADMINPASSWORD'
              secretRef: toLower('POSTGRES-ADMIN-PASSWORD')
            }
            {
              name: 'STRAPIPASSWORD'
              secretRef: toLower('POSTGRES-STRAPI-PASSWORD')
            }
            {
              name: 'ADMINUSER'
              value: administratorLogin
            }
            {
              name: 'SERVER'
              value: postgres.properties.fullyQualifiedDomainName
            }
            {
              name: 'STRAPIUSER'
              value: 'strapi'
            }
            {
              name: 'STRAPIDATABASENAME'
              value: 'strapi'
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'upload'
          storageName: 'upload'
          storageType: 'AzureFile'
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
