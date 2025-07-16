#!/bin/bash

# Load config file if present
CONFIG_FILE="${JETSON_RECORDER_CONF:-/etc/jetson-recorder.conf}"
if [ -f "${CONFIG_FILE}" ]; then
    # shellcheck source=/dev/null
    . "${CONFIG_FILE}"
fi

# Prepare timestamp variable for filenames
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Ensure output directory exists
mkdir -p "${OUTPUT_PATH}"

# Record video and GPS data with a common timestamp
ffmpeg -i rtsp://${USERNAME}:${PASSWORD}@${CAMERA_URL} -c copy "${OUTPUT_PATH}/${TIMESTAMP}_video.mkv" &

# Record GPS data from a serial device (e.g., /dev/ttyUSB1), add a timestamp to each line and skip empty lines
socat /dev/ttyUSB1,raw,echo=0 - | while IFS= read -r line; do
    [ -n "$line" ] && echo "$(date --iso=ns) $line"
done > "${OUTPUT_PATH}/${TIMESTAMP}_gps.log"
