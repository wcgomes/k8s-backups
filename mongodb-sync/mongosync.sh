#!/bin/bash

set -e

SCRIPT_NAME=mongodb-cluster-to-cluster-sync
DISABLE_TELEMETRY=""

if [ -n "$DISABLE_TELEMETRY" ]; then
	DISABLE_TELEMETRY="--disableTelemetry"
fi

# Print tool version
mongosync --version

echo ""
echo "[$SCRIPT_NAME] Starting..."

# Run mongosync
mongosync $DISABLE_TELEMETRY \
    --cluster0="$CLUSTER0_URI" \
    --cluster1="$CLUSTER1_URI" \
    --loadLevel="$LOAD_LEVEL" \
    --verbosity="$VERBOSITY"

echo "[$SCRIPT_NAME] Stopped."