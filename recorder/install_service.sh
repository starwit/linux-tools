#!/bin/bash

sudo systemctl disable --now recorder.service 2>/dev/null || true

# Remove old files (keep config)
sudo rm -f /etc/systemd/system/recorder.service
sudo rm -rf /opt/recorder

# Replace User=root with the current user in the service file
CURRENT_USER=$(whoami)
sed "s/User=root/User=$CURRENT_USER/g" recorder.service.tpl > recorder.service

# Copy new service and script files
sudo mkdir -p /opt/recorder
sudo cp recorder.sh /opt/recorder/
sudo cp recorder-cleanup.sh /opt/recorder/
sudo cp recorder.service /etc/systemd/system/

# Install default config if not present
if [ ! -f /etc/recorder.conf ]; then
    sudo bash -c 'cat > /etc/recorder.conf <<EOF
RTSP_URL=rtsp://username:password@127.0.0.1:8554            # Camera RTSP URL
OUTPUT_PATH=/tmp/recordings                                 # Path where all recorded files will be stored
NMEA_READ_COMMAND="gpspipe -r"                              # Command that outputs NMEA sentences
FILE_RETENTION_DAYS=7                                       # Automatically delete files after N days
EOF'
fi

sudo systemctl daemon-reload
sudo systemctl enable --now recorder.service

echo "Done. Service should be active. Check with 'systemctl status recorder.service'"
