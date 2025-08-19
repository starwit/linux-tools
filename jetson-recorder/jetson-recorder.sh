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
ffmpeg -i "${RTSP_URL}" -c copy -nostats "${OUTPUT_PATH}/${TIMESTAMP}_video.mkv" 2> "${OUTPUT_PATH}/${TIMESTAMP}_ffmpeg.log" &
FFMPEG_PID=$!

# Record GPS data from a serial device (e.g., /dev/ttyUSB1), add a timestamp to each line and skip empty lines
eval "${NMEA_READ_COMMAND}" | while IFS= read -r line; do
    [ -n "$line" ] && echo "$(date --iso=ns);$line"
done > "${OUTPUT_PATH}/${TIMESTAMP}_gps.log" &
GPS_PID=$!

echo "Recording started. FFMPEG PID: $FFMPEG_PID, GPS_PID: $GPS_PID"

# Wait for one of the processes to finish
wait -p job_id -n $FFMPEG_PID $GPS_PID

echo "Job $job_id exited. Stopping recording."