#!/bin/bash
set -euo pipefail

echo "= REMOTE START ="

REMOTE_PATH="/home/j1"
cd "$REMOTE_PATH"

# Check for folders of the form *imgXX*
LAST_IMG=$(ls -d *img[0-9][0-9]* 2>/dev/null | sort -V | tail -n 1)

if [ -z "$LAST_IMG" ]; then
    NEW_IMG_NUM="00"
else
    # Extract the first two digits
    LAST_IMG_NUM=$(echo "$LAST_IMG" | grep -o '[0-9]' | head -n2 | tr -d '\n')
    NEW_IMG_NUM=$((10#$LAST_IMG_NUM + 1))
    NEW_IMG_NUM=$(printf "%02d" "$NEW_IMG_NUM")
fi

# Build filename and run snapshot
NEW_IMG="img${NEW_IMG_NUM}.jpg"
FULL_FILE="$REMOTE_PATH/$NEW_IMG"

echo "Calling snapshot.sh with: $FULL_FILE"
./dtc-snapshot.sh "$FULL_FILE"

echo "recorded $FULL_FILE"
echo "= REMOTE DONE ="
