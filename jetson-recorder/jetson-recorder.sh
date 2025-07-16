#!/bin/bash

# Load config file if present
CONFIG_FILE="${JETSON_RECORDER_CONF:-/etc/jetson-recorder.conf}"
if [ -f "${CONFIG_FILE}" ]; then
    # shellcheck source=/dev/null
    . "${CONFIG_FILE}"
fi

# Prepare timestamp variable for filenames
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Placeholder for recording logic
# Example: LOGFILE="/some/path/recording_$TIMESTAMP.log"
# touch "$LOGFILE"

ffmpeg -i rtsp://${USERNAME}:${PASSWORD}@${CAMERA_URL} -c copy "${OUTPUT_PATH}/${TIMESTAMP}_video.mkv" &
socat /dev/ttyUSB1,raw,echo=0 - > "${OUTPUT_PATH}/${TIMESTAMP}_gps.log"
