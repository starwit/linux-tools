#!/bin/bash

sudo mkdir -p /opt/jetson-gpio-shutdown
sudo cp jetson-gpio-shutdown.sh /opt/jetson-gpio-shutdown/
sudo cp jetson-gpio-shutdown.service /etc/systemd/system/

# Install default config if not present
if [ ! -f /etc/jetson-gpio-shutdown.conf ]; then
    sudo bash -c 'cat > /etc/jetson-gpio-shutdown.conf <<EOF
# GPIO_PIN=105
# TIMEOUT_SECONDS=30
EOF'
fi

sudo systemctl daemon-reload
sudo systemctl enable --now jetson-gpio-shutdown.service

echo "Done. Service should be active. Check with 'systemctl status jetson-gpio-shutdown.service'"
