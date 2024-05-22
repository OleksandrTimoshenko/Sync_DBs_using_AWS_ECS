#!/bin/bash

echo "Starting script..."
# Check that variables exist
if [ -z "$SOURCE_DB_HOST" ] || [ -z "$TARGET_DB_POST" ] || [ -z "$SOURCE_DB_USER" ] || [ -z "$TARGET_DB_USER" ] || [ -z "$SOURCE_DB_NAME" ] || [ -z "$TARGET_DB_NAME" ] || [ -z "$SOURCE_DB_PASSWORD" ] || [ -z "$TARGET_DB_PASSWORD" ] || [ -z "$DUMP_NAME" ]; then
    echo "Error: Missing required environment variables."
    echo "Make sure to set SOURCE_DB_HOST, TARGET_DB_POST, SOURCE_DB_USER, TARGET_DB_USER, SOURCE_DB_NAME, TARGET_DB_NAME, SOURCE_DB_PASSWORD, TARGET_DB_PASSWORD, and DUMP_NAME."
    exit 1
fi

export PGPASSWORD=$SOURCE_DB_PASSWORD

echo "Creating backup of production database..."
pg_dump -h $SOURCE_DB_HOST -U $SOURCE_DB_USER -p 5432 -F custom $SOURCE_DB_NAME > /$DUMP_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to create backup of production database."
    exit 1
fi

export PGPASSWORD=$TARGET_DB_PASSWORD

echo "Terminating connections to the old staging database..."
# Terminating connections to the database
psql -h $TARGET_DB_POST -U $TARGET_DB_USER -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$TARGET_DB_NAME' AND pid <> pg_backend_pid();"
if [ $? -ne 0 ]; then
    echo "Error: Failed to terminate connections to the old staging database."
    exit 1
fi

echo "Dropping old stage database..."
dropdb -h $TARGET_DB_POST -U $TARGET_DB_USER -p 5432 --if-exists $TARGET_DB_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to drop old stage database."
    exit 1
fi

echo "Creating new stage database..."
createdb -h $TARGET_DB_POST -U $TARGET_DB_USER -p 5432 -T template0 $TARGET_DB_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to create new stage database."
    exit 1
fi

echo "Restoring stage database from backup..."
pg_restore --no-privileges --no-owner -h $TARGET_DB_POST -U $TARGET_DB_USER -p 5432 -d $TARGET_DB_NAME /$DUMP_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to restore stage database from backup."
    exit 1
fi

unset PGPASSWORD

echo "Backup and restore process completed successfully."