#!/bin/bash

sudo systemctl disable --now jetson-gpio-shutdown.service

# Remove service and related files
sudo rm -f /etc/systemd/system/jetson-gpio-shutdown.service
sudo rm -rf /opt/jetson-gpio-shutdown
sudo rm -f /etc/jetson-gpio-shutdown.conf

sudo systemctl daemon-reload

echo "Uninstall complete. Service and files removed."
