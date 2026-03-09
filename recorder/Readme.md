# recorder

A script and systemd service to automatically start a recording process on boot. The script prepares a timestamp variable for use in log or recording filenames.

## Installation

```sh
cd recorder
./install_service.sh
# Edit /etc/recorder.conf and set configuration options, then restart the service
sudo systemctl restart recorder.service
```

## Update

After making changes to the script or service file, reinstall:

```sh
./install_service.sh
```

## Uninstall

```sh
./uninstall_service.sh
```

## Configuration

Edit `/etc/recorder.conf` to override defaults or add options:

```sh
sudo vim /etc/recorder.conf
```

After changing the config, restart the service:

```sh
sudo systemctl restart recorder.service
```

## Set up cronjob to control data retention (i.e. delete after 7 days)
