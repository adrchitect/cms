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
});
