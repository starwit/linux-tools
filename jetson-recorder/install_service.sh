#!/bin/bash

sudo systemctl disable --now jetson-recorder.service 2>/dev/null || true

# Remove old files (keep config)
sudo rm -f /etc/systemd/system/jetson-recorder.service
sudo rm -rf /opt/jetson-recorder

# Copy new service and script files
sudo mkdir -p /opt/jetson-recorder
sudo cp jetson-recorder.sh /opt/jetson-recorder/
sudo cp jetson-recorder.service /etc/systemd/system/

# Install default config if not present
if [ ! -f /etc/jetson-recorder.conf ]; then
    sudo bash -c 'cat > /etc/jetson-recorder.conf <<EOF
USERNAME=username
PASSWORD=password
CAMERA_URL=127.0.0.1:8554
OUTPUT_PATH=/tmp/recordings
EOF'
fi

sudo systemctl daemon-reload
sudo systemctl enable --now jetson-recorder.service

echo "Done. Service should be active. Check with 'systemctl status jetson-recorder.service'"
