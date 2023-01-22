#!/bin/bash

set -e

SCRIPT_NAME=backup-postgres
BKP_DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME=pgdump_$BKP_DATE.sql

# Print tool version
pg_dumpall --version

echo "[$SCRIPT_NAME] Dumping all PostgreSQL databases to compressed archive..."

# Run database dump 
PGPASSWORD="$PG_PASSWORD" pg_dumpall -h $PG_HOST -p $PG_PORT -U $PG_USER > $ARCHIVE_NAME

# Compress backup file for upload
COMPRESSED_ARCHIVE_NAME=pgdump_$BKP_DATE.tar.gz
tar -zcvf "$COMPRESSED_ARCHIVE_NAME" "$ARCHIVE_NAME" 

# Recompress with password
COPY_NAME=$COMPRESSED_ARCHIVE_NAME
if [ ! -z "$PASSWORD_7ZIP" ]; then
    echo "[$SCRIPT_NAME] 7Zipping with password..."
    COPY_NAME=pgdump_$BKP_DATE.7z
    7za a -tzip -p"$PASSWORD_7ZIP" -mem=AES256 "$COPY_NAME" "$COMPRESSED_ARCHIVE_NAME"
fi

# S3 upload
S3_ENDPOINT_OPT=""
if [ ! -z "$S3_ENDPOINT_URL" ]; then
  S3_ENDPOINT_OPT="--endpoint $S3_ENDPOINT_URL"
fi

AWS_DEFAULT_OPT=""
if [ ! -z "$AWS_DEFAULT_REGION" ]; then
  AWS_DEFAULT_OPT="--region $AWS_DEFAULT_REGION"
fi

echo "[$SCRIPT_NAME] Uploading compressed archive to S3 bucket..."
aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 cp "$COPY_NAME" "$BUCKET_URI/$COPY_NAME"

echo "[$SCRIPT_NAME] Cleaning up compressed archive..."
rm "$COPY_NAME"
rm "$ARCHIVE_NAME" || true

echo "[$SCRIPT_NAME] Backup complete!"
