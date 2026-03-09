#!/bin/bash

# Load config file if present
CONFIG_FILE="${JETSON_RECORDER_CONF:-/etc/jetson-recorder.conf}"
if [ -f "${CONFIG_FILE}" ]; then
    # shellcheck source=/dev/null
    . "${CONFIG_FILE}"
fi

# Find and delete files older than retention period
find "${OUTPUT_PATH}" -type f -mtime +"${FILE_RETENTION_DAYS}" -exec rm -f {} \;