#!/bin/bash

set -e

SCRIPT_NAME=backup-mongodb
OPLOG_FLAG=""
OPLOG_REPLAY_FLAG=""
MONGODB_NSINCLUDE_FLAG=""
MONGODB_NSEXCLUDE_FLAG=""

# print tool version
mongodump --version
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

## flags mongodb
if [ "$MONGODB_OPLOG" = "true" ]; then
  echo "[$SCRIPT_NAME] OPLOG Enabled."
  
  OPLOG_FLAG="--oplog"
  OPLOG_REPLAY_FLAG="--oplogReplay"
fi

# backup
if [ ! -z "$MONGODB_URI" ]; then

  ARCHIVE_NAME=mongodump_$(date +%Y%m%d_%H%M%S).gz

  echo "[$SCRIPT_NAME] Dumping all MongoDB databases to compressed archive..."

  # run database dump
  mongodump $OPLOG_FLAG \
    --archive="$ARCHIVE_NAME" \
    --gzip \
    --uri "$MONGODB_URI"

  # recompress with password
  if [ ! -z "$PASSWORD_7ZIP" ]; then
    echo "[$SCRIPT_NAME] 7Zipping with password..."

    COPY_NAME=${ARCHIVE_NAME//gz/7z}
    7za a -tzip -mem=AES256 -p"$PASSWORD_7ZIP" "$COPY_NAME" "$ARCHIVE_NAME"
  else
    COPY_NAME=$ARCHIVE_NAME
  fi

  # upload backup
  echo "[$SCRIPT_NAME] Uploading compressed archive to S3 storage..."

  aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 cp "$COPY_NAME" "$BUCKET_URI/$COPY_NAME"

  echo "[$SCRIPT_NAME] Backup complete!"
fi

# restore
if [ ! -z "$MONGODB_RESTORE_URI" ]; then
  if [ -z "$MONGODB_URI" ]; then
    echo "[$SCRIPT_NAME] Downloading backup from S3 storage..."

    COPY_NAME=$(aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 ls "$BUCKET_URI" --recursive | sort | tail -n 1 | awk -F"/" '{print $NF}')

    # download backup
    aws ${S3_ENDPOINT_OPT} ${AWS_DEFAULT_OPT} s3 cp "$BUCKET_URI/$COPY_NAME" "$COPY_NAME"

    # decompress with password
    if [ ! -z "$PASSWORD_7ZIP" ]; then
      echo "[$SCRIPT_NAME] Decompressing with password..."

      7za x -tzip -mem=AES256 -p"$PASSWORD_7ZIP" "$COPY_NAME"

      ARCHIVE_NAME=${COPY_NAME//7z/gz}
    else
      ARCHIVE_NAME=$COPY_NAME
    fi
  fi

  echo "[$SCRIPT_NAME] Restoring MongoDB dump..."

  # check if restore uri contains "mongodb.net"
  # https://www.mongodb.com/docs/atlas/import/mongorestore/#cluster-security
  if [[ $MONGODB_RESTORE_URI == *"mongodb.net"* ]]; then
      echo "[$SCRIPT_NAME] Excluding admin.system.* to Atlas Cluster restore."

      # run database restore to atlas cluster
      mongorestore $OPLOG_REPLAY_FLAG \
        --archive="$ARCHIVE_NAME" \
        --uri "$MONGODB_RESTORE_URI" \
        --nsExclude "admin.system.*" \
        --gzip \
        --drop
  else
      # run database restore
      mongorestore $OPLOG_REPLAY_FLAG \
        --archive="$ARCHIVE_NAME" \
        --uri "$MONGODB_RESTORE_URI" \
        --gzip \
        --drop
  fi

  echo "[$SCRIPT_NAME] Restore complete!"
fi

# cleanup
echo "[$SCRIPT_NAME] Cleaning up..."

if test -e "$COPY_NAME"; then
  rm "$COPY_NAME"
fi

if test -e "$ARCHIVE_NAME"; then
  rm "$ARCHIVE_NAME"
fi

echo "[$SCRIPT_NAME] Finished!"
