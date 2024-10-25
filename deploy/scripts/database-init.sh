#! /bin/sh

# URL encode both passwords for connection strings
ADMIN_URL_PASSWORD=$(printf %s "$ADMINPASSWORD" | od -An -tx1 | tr ' ' % | tr -d '\n')
STRAPI_URL_PASSWORD=$(printf %s "$STRAPIPASSWORD" | od -An -tx1 | tr ' ' % | tr -d '\n')

# For SQL, we need to escape single quotes by doubling them
SQL_ESCAPED_PASSWORD=$(printf %s "$STRAPIPASSWORD" | awk "{gsub(/'/,\"''\"); print}")

# Commands using admin credentials with encoded password
psql -d "postgresql://$ADMINUSER:$ADMIN_URL_PASSWORD@$SERVER/postgres" -c "CREATE USER $STRAPIUSER WITH PASSWORD '$SQL_ESCAPED_PASSWORD';" || true
psql -d "postgresql://$ADMINUSER:$ADMIN_URL_PASSWORD@$SERVER/postgres" -c "GRANT CONNECT ON DATABASE $STRAPIDATABASENAME TO $STRAPIUSER;"
psql -d "postgresql://$ADMINUSER:$ADMIN_URL_PASSWORD@$SERVER/postgres" -c "GRANT CREATE ON DATABASE $STRAPIDATABASENAME TO $STRAPIUSER;"

# Use the URL encoded Strapi password in the connection string
psql -d "postgresql://$STRAPIUSER:$STRAPI_URL_PASSWORD@$SERVER/$STRAPIDATABASENAME" -c "CREATE SCHEMA $STRAPIUSER AUTHORIZATION $STRAPIUSER;" || true
