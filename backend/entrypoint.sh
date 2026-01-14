#!/bin/sh
set -e

if [ -n "${SKIP_DB_INIT}" ]; then
  echo "Skipping database initialization."
elif [ -n "${DATABASE_URL}" ]; then
  echo "Waiting for database..."
  until pg_isready -d "${DATABASE_URL}" >/dev/null 2>&1; do
    sleep 1
  done

  echo "Initializing database schema..."
  npx prisma migrate deploy --schema=src/prisma/schema.prisma || true
  npx prisma db push --schema=src/prisma/schema.prisma
  echo "Seeding database..."
  npm run seed
fi

exec node src/index.js
