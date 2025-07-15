# Linux Tools
This repository contains a list of tools for the Linux operating system.


## Installable APT packages
Following tools are supposed to be installable as APT packages.

### RTSP Recorder
Simple tool to record videos from an IP camera. Can be used on an embedded device to automatically make recordings. More details [here](rtsp-recorder/Readme.md)

### Valkey
For Ubuntu versions earlier than 24 there is no ValKey package. This creates an APT package for amd64 and arm64. More details [here](valkey/Readme.md)

## Manually installable systemd services (lacking apt ATM)

### wol-http-trigger
Wake up devices through Wake-On-LAN over simple web frontend or HTTP.

### auto-shutdown
A script and a systemd timed service to automatically shut down a machine if it is presumably not used.

### connection-monitor
A bash script to monitor network connectivity using configurable check methods (ICMP, HTTP).