#!/bin/bash

# Source environment file if it exists
if [ -f /etc/starwit/rtsp-recorder/env.sh ]; then
    source /etc/starwit/rtsp-recorder/env.sh
fi

# Generate timestamp for filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="recording_${TIMESTAMP}.mp4"

# Record RTSP stream
ffmpeg -i rtsp://$USERNAME:$PASSWORD@$CAMERA_URI/ -c copy "$TARGETDIR/$FILENAME"
