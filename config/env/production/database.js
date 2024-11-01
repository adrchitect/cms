module.exports = ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: env('DATABASE_HOST', env('POSTGRES_HOST')),
      port: env.int('DATABASE_PORT', env('POSTGRES_PORT')),
      database: env('DATABASE_NAME', env('POSTGRES_DATABASE')),
      user: env('DATABASE_USERNAME', env('POSTGRES_USERNAME')),
      password: env('DATABASE_PASSWORD', env('POSTGRES_PASSWORD')),
      ssl: env.bool('DATABASE_SSL', false),
    },
  },
});
