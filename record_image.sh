#!/bin/bash
set -euo pipefail

echo "=== RECORD START ==="

# Check if the IP address is passed as an argument
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP_ADDRESS="$1"
REMOTE_USER="j1"
REMOTE_SCRIPT="/home/j1/dtc-snapshot.sh"

echo "ssh into $REMOTE_USER@$IP_ADDRESS..."
ssh "$REMOTE_USER@$IP_ADDRESS" "bash \"$REMOTE_SCRIPT\""

echo "=== RECORD DONE ==="

