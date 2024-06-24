param defaultName string
param location string
param appIdentityId string
param keyvaultName string
param postgresDbUri string

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

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'asp-${defaultName}'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: 'app-${defaultName}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        {
          name: 'APP_KEYS'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('APP-KEYS')})'
        }
        {
          name: 'API_TOKEN_SALT'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('API-TOKEN-SALT')})'
        }
        {
          name: 'ADMIN_JWT_SECRET'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('ADMIN-JWT-SECRET')})'
        }
        {
          name: 'TRANSFER_TOKEN_SALT'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('TRANSFER-TOKEN-SALT')})'
        }
        {
          name: 'JWT_SECRET'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('JWT-SECRET')})'
        }
        {
          name: 'DATABASE_CLIENT'
          value: 'postgres'
        }
        {
          name: 'DATABASE_HOST'
          value: postgresDbUri
        }
        {
          name: 'DATABASE_NAME'
          value: 'postgres'
        }
        {
          name: 'DATABASE_SSL'
          value: 'true'
        }
        {
          name: 'DATABASE_PORT'
          value: '5432'
        }
        {
          name: 'DATABASE_USERNAME'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('DATABASE-USERNAME')})'
        }
        {
          name: 'DATABASE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('DATABASE-PASSWORD')})'
        }
      ]
    }
  }
}


output appUrl string = webApplication.properties.defaultHostName
