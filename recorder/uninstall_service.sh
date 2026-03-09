#!/bin/bash

sudo systemctl disable --now recorder.service

# Remove service and related files
sudo rm -f /etc/systemd/system/recorder.service
sudo rm -rf /opt/recorder
sudo rm -f /etc/recorder.conf

sudo systemctl daemon-reload

echo "Uninstall complete. Service and files removed."
