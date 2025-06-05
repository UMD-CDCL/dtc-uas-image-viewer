#!/bin/bash
set -euo pipefail

waittime=20

echo "= REMOTE START ="

REMOTE_PATH="/home/j1/images"
cd "$REMOTE_PATH"

# Enable nullglob so patterns that don't match expand to nothing
shopt -s nullglob

# Get list of matching files (if any)
matching_files=(*img[0-9][0-9]*)

if [ ${#matching_files[@]} -eq 0 ]; then
    NEW_IMG_NUM="00"
else
    # Sort and get the last matching file
    LAST_IMG=$(printf "%s\n" "${matching_files[@]}" | sort -V | tail -n 1)
    # Extract the first two digits
    LAST_IMG_NUM=$(echo "$LAST_IMG" | grep -o '[0-9]' | head -n2 | tr -d '\n')
    NEW_IMG_NUM=$((10#$LAST_IMG_NUM + 1))
    NEW_IMG_NUM=$(printf "%02d" "$NEW_IMG_NUM")
fi

echo $NEW_IMG_NUM
HEADER="img${NEW_IMG_NUM}"

# Generate batch timestamp
BATCH_TS="$(date +"%Y%m%d_%H%M%S")"

# Detect thermal device
if ! command -v v4l2-ctl &> /dev/null; then
  echo "Error: v4l2-ctl not found. Please install v4l-utils." >&2
  exit 1
fi

THERMAL_DEV=$(v4l2-ctl --list-devices | awk '/Boson: FLIR Video/{getline; print $1}')
if [[ -z "$THERMAL_DEV" ]]; then
  echo "Error: FLIR Boson device not found." >&2
  exit 1
fi

echo "Waiting $waittime second and capturing last RGB frame..."

# Capture last RGB frame using filesink
gst-launch-1.0 -e \
  nvarguscamerasrc sensor-id=0 wbmode=1 ! \
  queue max-size-buffers=1 leaky=downstream ! \
  'video/x-raw(memory:NVMM), width=3840, height=2160, framerate=1/1' ! \
  nvvidconv flip-method=2 ! \
  'video/x-raw,format=I420' ! \
  videoconvert ! \
  'video/x-raw,format=RGB' ! \
  pngenc ! \
  multifilesink location="${HEADER}_rgb_${BATCH_TS}.png" &
  
# Let the pipeline run for a few seconds for image to stabilize, then kill it
PIPE_PID=$!
sleep $waittime
kill $PIPE_PID
wait $PIPE_PID 2>/dev/null || true


echo "Capturing thermal snapshot..."

# Capture thermal frame
gst-launch-1.0 -e \
  v4l2src device="${THERMAL_DEV}" num-buffers=1 ! \
  queue max-size-buffers=1 ! \
  video/x-raw,width=640,height=512,format=I420 ! \
  videoconvert ! \
  pngenc ! \
  multifilesink location="${HEADER}_thermal_${BATCH_TS}.png"


echo "All images captured successfully."


echo "recorded $HEADER"
echo "= REMOTE DONE ="
