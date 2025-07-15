# jetson-gpio-shutdown

A script and systemd service to automatically shut down a Jetson device if a configured GPIO pin (DI1-DI4) is low for a configurable amount of time. The digital input value is checked once a second.

## Installation

```sh
cd jetson-gpio-shutdown
sudo ./install_service.sh
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

Edit `/etc/jetson-gpio-shutdown.conf` to override defaults:

```sh
sudo vim /etc/jetson-gpio-shutdown.conf
```

Example config:

```
GPIO_PIN=105
TIMEOUT_SECONDS=30
```

- `GPIO_PIN`: The GPIO pin number to monitor (default: 105)
- `TIMEOUT_SECONDS`: Seconds the pin must remain low before shutdown (default: 30)

After changing the config, restart the service:

```sh
sudo systemctl restart jetson-gpio-shutdown.service
```
