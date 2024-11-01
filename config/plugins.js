module.exports = ({ env }) => ({
  email: {
    config: {
      provider: 'strapi-provider-email-azure',
      providerOptions: {
        endpoint: env('AZURE_ENDPOINT'),
      },
      settings: {
        defaultFrom: env('FALLBACK_EMAIL'),
      },
    },
  },
  upload: {
    config: {
      provider: "@physer/strapi-provider-upload-azure-storage",
      providerOptions: {
        authType: env("STORAGE_AUTH_TYPE", "default"),
        clientId: env("AZURE_CLIENT_ID"),
        account: env("STORAGE_ACCOUNT"),
        accountKey: env("STORAGE_ACCOUNT_KEY"),//either account key or sas token is enough to make authentication
        sasToken: env("STORAGE_ACCOUNT_SAS_TOKEN"),
        serviceBaseURL: env("STORAGE_URL"), // optional
        containerName: env("STORAGE_CONTAINER_NAME"),
        createContainerIfNotExist: env("STORAGE_CREATE_CONTAINER_IF_NOT_EXIST", 'false'), // optional
        publicAccessType: env("STORAGE_PUBLIC_ACCESS_TYPE"), // optional ('blob' | 'container')
        defaultPath: "assets",
        cdnBaseURL: env("STORAGE_CDN_URL"), // optional
        defaultCacheControl: env("STORAGE_CACHE_CONTROL"), // optional
        removeCN: env("REMOVE_CONTAINER_NAME"), // optional, if you want to remove container name from the URL
      },
    },
  },
});
