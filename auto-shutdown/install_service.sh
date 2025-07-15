#!/bin/bash

sudo mkdir -p /etc/auto-shutdown
sudo cp auto-shutdown.sh /etc/auto-shutdown/
sudo cp ./auto-shutdown.{service,timer} /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now auto-shutdown.timer

echo "Done. Timer should be active. Check with 'systemctl list-timers'"