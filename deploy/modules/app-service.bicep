param defaultName string
param location string
param appIdentityId string
param keyvaultName string
param postgresDbUri string
param applicationTag string

var webApplicationName = applicationTag == '' ? 'app-${defaultName}' : 'app-${defaultName}-${applicationTag}'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: 'asp-${defaultName}'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: 'appi-${defaultName}'
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: webApplicationName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appIdentityId}': {}
    }
  }
  properties: {
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      appCommandLine: 'npm run start-appservice'
    }
    serverFarmId: appServicePlan.id
    keyVaultReferenceIdentity: appIdentityId
  }

  resource appsettings 'config' = {
    name: 'appsettings'
    properties: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
      XDT_MicrosoftApplicationInsights_Mode: 'default'
      WEBSITE_RUN_FROM_PACKAGE: '1'
      APP_KEYS: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('APP-KEYS')})'
      API_TOKEN_SALT: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('API-TOKEN-SALT')})'
      ADMIN_JWT_SECRET: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('ADMIN-JWT-SECRET')})'
      TRANSFER_TOKEN_SALT: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('TRANSFER-TOKEN-SALT')})'
      JWT_SECRET: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('JWT-SECRET')})'
      DATABASE_CLIENT: 'postgres'
      DATABASE_HOST: postgresDbUri
      DATABASE_NAME: 'postgres'
      DATABASE_SSL: 'true'
      DATABASE_PORT: '5432'
      DATABASE_USERNAME: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('DATABASE-USERNAME')})'
      DATABASE_PASSWORD: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${toLower('DATABASE-PASSWORD')})'
    }
  }
}

output appUrl string = webApplication.properties.defaultHostName
