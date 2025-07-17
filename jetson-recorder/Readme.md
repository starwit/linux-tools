# jetson-recorder

A script and systemd service to automatically start a recording process on boot. The script prepares a timestamp variable for use in log or recording filenames.

## Installation

```sh
cd jetson-recorder
sudo ./install_service.sh
# Edit /etc/jetson-recorder.conf and set configuration options, then restart the service
sudo systemctl restart jetson-recorder.service
```

## Update

After making changes to the script or service file, reinstall:

```sh
sudo ./install_service.sh
```

## Uninstall

```sh
sudo ./uninstall_service.sh
```

## Configuration

Edit `/etc/jetson-recorder.conf` to override defaults or add options:

```sh
sudo vim /etc/jetson-recorder.conf
```

After changing the config, restart the service:

```sh
sudo systemctl restart jetson-recorder.service
```
