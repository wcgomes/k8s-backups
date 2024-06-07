#!/bin/bash

set -e

SCRIPT_NAME="[backup-postgresql]"

# print tool version
pg_dumpall --version
echo ""

# s3 storage
S3_ENDPOINT_OPT=""
if [ ! -z "$S3_ENDPOINT_URL" ]; then
  S3_ENDPOINT_OPT="--endpoint $S3_ENDPOINT_URL"
fi

AWS_DEFAULT_OPT=""
if [ ! -z "$AWS_DEFAULT_REGION" ]; then
  AWS_DEFAULT_OPT="--region $AWS_DEFAULT_REGION"
fi

# backup
if [ ! -z "$PG_HOST" ]; then

  ARCHIVE_NAME=pgdump_$(date +%Y%m%d_%H%M%S).sql

  echo "$SCRIPT_NAME Dumping all PostgreSQL databases..."

  # run database dump
  PGPASSWORD="$PG_PASSWORD" pg_dumpall -h $PG_HOST -p $PG_PORT -U $PG_USER --clean --if-exists > pgdumpall.sql

  # adding WITH (FORCE) to DROP DATABASE commands
  sed '/DROP DATABASE/ s/;$/ WITH (FORCE);/' pgdumpall.sql > $ARCHIVE_NAME

  # compress backup file for upload
  echo "$SCRIPT_NAME Compressing files..."
  COMPRESSED_ARCHIVE_NAME=${ARCHIVE_NAME//sql/tar.gz}
  tar -zcvf "$COMPRESSED_ARCHIVE_NAME" "$ARCHIVE_NAME"

  # recompress with password
  if [ ! -z "$PASSWORD_7ZIP" ]; then
    echo "$SCRIPT_NAME 7Zipping with password..."

    COPY_NAME=${COMPRESSED_ARCHIVE_NAME//tar.gz/7z}
    7za a -tzip -mem=AES256 -p"$PASSWORD_7ZIP" "$COPY_NAME" "$COMPRESSED_ARCHIVE_NAME"
  else
    COPY_NAME=$COMPRESSED_ARCHIVE_NAME
  fi

  echo "$SCRIPT_NAME Uploading compressed archive to S3 bucket..."

  aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 cp "$COPY_NAME" "$BUCKET_URI/$COPY_NAME"

  echo "$SCRIPT_NAME Backup complete!"
fi

if [ ! -z "$PG_RESTORE_HOST" ]; then
  if [ -z "$PG_HOST" ]; then
    echo "$SCRIPT_NAME Downloading backup from S3 storage..."

    COPY_NAME=$(aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 ls "$BUCKET_URI" --recursive | sort | tail -n 1 | awk -F"/" '{print $NF}')

    # download backup
    aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 cp "$BUCKET_URI/$COPY_NAME" "$COPY_NAME"

    # decompress with password
    if [ ! -z "$PASSWORD_7ZIP" ]; then
      echo "$SCRIPT_NAME Decompressing with password..."

      7za x -tzip -mem=AES256 -p"$PASSWORD_7ZIP" "$COPY_NAME"
      COMPRESSED_ARCHIVE_NAME=${COPY_NAME//7z/tar.gz}
    else
      COMPRESSED_ARCHIVE_NAME=$COPY_NAME
    fi

    # decompress tag.gz
    echo "$SCRIPT_NAME Decompressing files..."

    ARCHIVE_NAME=${COMPRESSED_ARCHIVE_NAME//tar.gz/sql}
    tar -xzf "$COMPRESSED_ARCHIVE_NAME"
  fi

  echo "$SCRIPT_NAME Restoring PostgreSQL dump..."

  # avoid dropping/creating current user
  sed -i "/DROP ROLE IF EXISTS $PG_USER;/ s/^/-- /" "$ARCHIVE_NAME"
  sed -i "/CREATE ROLE $PG_USER;/ s/^/-- /" "$ARCHIVE_NAME"

  # run database restore
  PGPASSWORD="$PG_PASSWORD" psql -v ON_ERROR_STOP=1 -f "$ARCHIVE_NAME" -h $PG_RESTORE_HOST -p $PG_PORT -U $PG_USER $PG_DATABASE

  echo "$SCRIPT_NAME Restore complete!"
fi

# cleanup
echo "$SCRIPT_NAME Cleaning up..."

if test -e "$COPY_NAME"; then
  rm "$COPY_NAME"
fi

if test -e "$ARCHIVE_NAME"; then
  rm "$ARCHIVE_NAME"
fi

if test -e "$COMPRESSED_ARCHIVE_NAME"; then
  rm "$COMPRESSED_ARCHIVE_NAME"
fi

if test -e "postscript.sh"; then
  echo "$SCRIPT_NAME Post processing script..."
  source postscript.sh
fi

echo "$SCRIPT_NAME Finished!"