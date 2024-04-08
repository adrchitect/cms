module.exports =  ({ env }) => ({
	connection: {
		client: 'postgres',
		connection: {
		host: env('POSTGRES_HOST', 'localhost'),
			port: env.int('POSTGRES_PORT', 5432),
			database: env('POSTGRES_DATABASE', 'strapi'),
			user: env('POSTGRES_USERNAME', 'strapi'),
			password: env('POSTGRES_PASSWORD', 'strapi'),
			ssl: env.bool('POSTGRES_SSL', false)
		}
	}
});
