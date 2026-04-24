#!/bin/bash
set -e

# Ensure tmp directories exist and remove any stale PID file
mkdir -p /app/tmp/pids
rm -f /app/tmp/pids/server.pid

# Run database migrations
echo "Running database migrations..."
bundle exec rails db:create db:migrate

echo "Starting application..."
exec "$@"
