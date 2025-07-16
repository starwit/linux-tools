#!/bin/bash

sudo systemctl disable --now jetson-recorder.service

# Remove service and related files
sudo rm -f /etc/systemd/system/jetson-recorder.service
sudo rm -rf /opt/jetson-recorder
sudo rm -f /etc/jetson-recorder.conf

sudo systemctl daemon-reload

echo "Uninstall complete. Service and files removed."
