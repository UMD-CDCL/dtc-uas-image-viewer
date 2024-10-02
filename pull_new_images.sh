#!/bin/bash

echo "=== PULL START ==="

if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

# Define variables
REMOTE_USER="root"
IP_ADDRESS=$1
REMOTE_DIR="/data/images/"
LOCAL_DIR="$HOME/Documents/dtc"
LOG_FILE="$LOCAL_DIR/rsync_log.txt"

# Pull new images from the remote directory and log the names of transferred files
echo "rsync into $REMOTE_USER@$IP_ADDRESS..."
rsync -az --ignore-existing --include='img[0-9][0-9].jpg' --exclude=* --progress $REMOTE_USER@$IP_ADDRESS:$REMOTE_DIR $LOCAL_DIR

echo "=== PULL DONE ==="
