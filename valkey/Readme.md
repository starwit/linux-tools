# Valkey as SystemD service

This repo installs Valkey on Ubuntu 22.04 systems. Please note that since Ubuntu 24.04 valkey is available via APT:
```bash
apt-get install valkey
```

So this is just a workaround for anyone using Valkey on earlier versions of Ubuntu

## How to build

Run the following commands
```bash
export ARCH=arm64
./build_package.sh
```

Depending on provided archicture you'll find APT package in a folder named $ARCH

## How to install

```bash
apt-get install ./valkey-server...
```
