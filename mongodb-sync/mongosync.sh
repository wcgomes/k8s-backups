#!/bin/bash

set -e

SCRIPT_NAME=mongodb-cluster-to-cluster-sync

# Print tool version
mongosync --version

echo ""
echo "[$SCRIPT_NAME] Starting..."

# Run mongosync
mongosync \
    --cluster0="$CLUSTER0_URI" \
    --cluster1="$CLUSTER1_URI" \
    --loadLevel="$LOAD_LEVEL" \
    --verbosity="$VERBOSITY" \
    --disableTelemetry 

echo "[$SCRIPT_NAME] Stopped."