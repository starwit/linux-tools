#!/bin/bash

mkdir -p ~/.config/systemd/user
sed "s:PATH_TO_SERVER_SCRIPT:$(pwd)/wol_http_server.py:" wol-http-trigger.service > ~/.config/systemd/user/wol-http-trigger.service

loginctl enable-linger
systemctl --user enable wol-http-trigger.service
systemctl --user start wol-http-trigger.service

echo "Done. Service should be running. Check with 'systemctl --user status wol-http-trigger.service'"