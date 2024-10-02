#!/bin/bash

echo "=== NEW TEST START ==="

# Check if the IP address is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP_ADDRESS=$1
REMOTE_USER="root"
REMOTE_PATH="/data/images"
TESTS_DIR="current-tests"
LOCAL_PATH="$HOME/Documents/dtc"

# SSH into the remote machine and check for directories
echo "ssh into $REMOTE_USER@$IP_ADDRESS..."

ssh "$REMOTE_USER@$IP_ADDRESS" "setsid bash -c 'bash -s' << 'EOF'
echo "= REMOTE START ="

# go to remote images folder
TESTS_DIR=$TESTS_DIR
REMOTE_PATH=$REMOTE_PATH
cd \$REMOTE_PATH
echo "cd \$REMOTE_PATH"

# check that the tes dir exists, if not, create it
if [ ! -d "\$TESTS_DIR" ]; then
  # Directory does not exist, create it
  mkdir \$TESTS_DIR
  echo "created \$TESTS_DIR"
fi

# Check for folders of the form test##
LAST_FOLDER=\$(ls -d \$TESTS_DIR/test[0-9][0-9] 2>/dev/null | sort -V | tail -n 1)

# if no test%02d folders exist, set number to 0
if [ -z "\$LAST_FOLDER" ]; then
    NEW_FOLDER_NUM="00"
else # set number to last+1
    # Extract the number from the last folder name
    FOLDER_NUM=\${LAST_FOLDER:\$((\${#LAST_FOLDER}-2)):2}
    NEW_FOLDER_NUM=\$((10#\$FOLDER_NUM + 1))
fi

# make new folder
NEW_FOLDER=\$(printf "test%02d" "\$NEW_FOLDER_NUM")
FULL_FOLDER_PATH="\$REMOTE_PATH/\$TESTS_DIR/\$NEW_FOLDER"
mkdir \$FULL_FOLDER_PATH
echo "created \$FULL_FOLDER_PATH"

# move images to new folder
mv \$REMOTE_PATH/img*.jpg \$FULL_FOLDER_PATH
echo "moved \$REMOTE_PATH/img*.jpg to \$FULL_FOLDER_PATH"
echo "= REMOTE DONE ="
EOF
"
echo "= LOCAL START ="
# check that the tests dir exists, if not, create it
if [ ! -d "$TESTS_DIR" ]; then
  # Directory does not exist, create it
  mkdir "$TESTS_DIR"
  echo "created $TESTS_DIR"
fi

# Check for folders of the form test##
LAST_FOLDER=$(ls -d $TESTS_DIR/test[0-9][0-9] 2>/dev/null | sort -V | tail -n 1)
# if no test%02d folders exist, set number to 0
if [ -z "$LAST_FOLDER" ]; then
    NEW_FOLDER_NUM="00"
else # set number to last+1
    # Extract the number from the last folder name
    FOLDER_NUM=${LAST_FOLDER:$((${#LAST_FOLDER}-2)):2}
    NEW_FOLDER_NUM=$((10#$FOLDER_NUM + 1))
fi

# make new folder
NEW_FOLDER=$(printf "test%02d" "$NEW_FOLDER_NUM")
FULL_FOLDER_PATH="$LOCAL_PATH/$TESTS_DIR/$NEW_FOLDER"
mkdir $FULL_FOLDER_PATH
echo "created $FULL_FOLDER_PATH"

# move images to new folder
mv $LOCAL_PATH/img*.jpg $FULL_FOLDER_PATH
echo "moved $LOCAL_PATH/img* to $TESTS_DIR/$NEW_FOLDER"
echo "= LOCAL DONE ="

echo "=== NEW TEST DONE ==="
