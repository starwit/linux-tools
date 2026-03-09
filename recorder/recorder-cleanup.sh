#!/bin/bash

# Load config file if present
CONFIG_FILE="${RECORDER_CONF:-/etc/recorder.conf}"
if [ -f "${CONFIG_FILE}" ]; then
    # shellcheck source=/dev/null
    . "${CONFIG_FILE}"
fi

# Find and delete files older than retention period
find "${OUTPUT_PATH}" -type f -mtime +"${FILE_RETENTION_DAYS}" -exec rm -f {} \;