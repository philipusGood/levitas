#!/bin/bash
set -e

# Remove any stale server PID file (can block startup after unclean shutdown)
rm -f /app/tmp/pids/server.pid

# Run database migrations
echo "Running database migrations..."
bundle exec rails db:create db:migrate

echo "Starting application..."
exec "$@"
