#!/bin/bash

echo "=== RECORD START ==="

# Check if the IP address is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP_ADDRESS=$1
REMOTE_USER="root"
REMOTE_PATH="/data/images"

# SSH into the remote machine and check for directories
echo "ssh into $REMOTE_USER@$IP_ADDRESS..."
ssh "$REMOTE_USER@$IP_ADDRESS" "setsid bash -c 'bash -s' << 'EOF'
echo "= REMOTE START ="

# go to remote images folder
REMOTE_PATH="/data/images"
cd \$REMOTE_PATH

# Check for folders of the form testXX
LAST_IMG=\$(ls -d img[0-9][0-9].jpg 2>/dev/null | sort -V | tail -n 1)

# if no img%02d.jpg files exist, set number to 0
if [ -z "\$LAST_IMG" ]; then
    NEW_IMG_NUM="00"
else # set number to last+1
    # Extract the number from the last folder name
    LAST_IMG_NUM=\${LAST_IMG:\$((\${#LAST_IMG}-6)):2}
    NEW_IMG_NUM=\$((10#\$LAST_IMG_NUM + 1))
fi

# make new file based of number
NEW_IMG=\$(printf "img%02d.jpg" "\$NEW_IMG_NUM")
FULL_FILE="\$REMOTE_PATH/\$NEW_IMG"
voxl-send-command hires_snapshot snapshot \$FULL_FILE
echo "recorded \$FULL_FILE"
echo "= REMOTE DONE ="
EOF
"

echo "=== RECORD DONE ==="
