#!/bin/bash

echo "=== NEW RUN START ==="

# Check if the IP address is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP_ADDRESS=$1
REMOTE_USER="root"
REMOTE_PATH="/data/images"
TESTS_DIR="current-tests"
RUNS_DIR="current-runs"
LOCAL_PATH="$HOME/Documents/dtc"

# SSH into the remote machine and check for directories
echo "ssh into $REMOTE_USER@$IP_ADDRESS..."

ssh "$REMOTE_USER@$IP_ADDRESS" "setsid bash -c 'bash -s' << 'EOF'
echo "= REMOTE START ="

# go to remote images folder
RUNS_DIR=$RUNS_DIR
TESTS_DIR=$TESTS_DIR
REMOTE_PATH=$REMOTE_PATH
cd \$REMOTE_PATH

# check that the run dir exists, if not, create it
if [ ! -d "\$RUNS_DIR" ]; then
  # Directory does not exist, create it
  mkdir "\$RUNS_DIR"
  echo "created \$RUNS_DIR"
fi

# Check for folders of the form run##
LAST_FOLDER=\$(ls -d \$RUNS_DIR/run[0-9][0-9] 2>/dev/null | sort -V | tail -n 1)

# if no run%02d folders exist, set number to 0
if [ -z "\$LAST_FOLDER" ]; then
    NEW_FOLDER_NUM="00"
else # set number to last+1
    # Extract the number from the last folder name
    FOLDER_NUM=\${LAST_FOLDER:\$((\${#LAST_FOLDER}-2)):2}
    NEW_FOLDER_NUM=\$((10#\$FOLDER_NUM + 1))
fi

# make new folder
NEW_FOLDER=\$(printf "run%02d" "\$NEW_FOLDER_NUM")
FULL_FOLDER_PATH="\$REMOTE_PATH/\$RUNS_DIR/\$NEW_FOLDER"
mkdir \$FULL_FOLDER_PATH
echo "created \$FULL_FOLDER_PATH"

# move images to new folder
mv \$TESTS_DIR/test* \$FULL_FOLDER_PATH
echo "moved \$TESTS_DIR/test* to \$FULL_FOLDER_PATH"
echo "= REMOTE DONE ="
EOF
"

echo "= LOCAL START ="
# check that the run dir exists, if not, create it
if [ ! -d "$RUNS_DIR" ]; then
  # Directory does not exist, create it
  mkdir "$RUNS_DIR"
  echo "created $RUNS_DIR"
fi

# Check for folders of the form run##
LAST_FOLDER=$(ls -d $RUNS_DIR/run[0-9][0-9] 2>/dev/null | sort -V | tail -n 1)
# if no run%02d folders exist, set number to 0
if [ -z "$LAST_FOLDER" ]; then
    NEW_FOLDER_NUM="00"
else # set number to last+1
    # Extract the number from the last folder name
    FOLDER_NUM=${LAST_FOLDER:$((${#LAST_FOLDER}-2)):2}
    NEW_FOLDER_NUM=$((10#$FOLDER_NUM + 1))
fi

# make new folder
NEW_FOLDER=$(printf "run%02d" "$NEW_FOLDER_NUM")
FULL_FOLDER_PATH="$LOCAL_PATH/$RUNS_DIR/$NEW_FOLDER"
mkdir $FULL_FOLDER_PATH
echo "created $FULL_FOLDER_PATH"

# move images to new folder
mv $TESTS_DIR/test* $FULL_FOLDER_PATH
echo "moved $TESTS_DIR/test* to $FULL_FOLDER_PATH"

echo "= LOCAL DONE ="
echo "=== NEW RUN DONE =="
