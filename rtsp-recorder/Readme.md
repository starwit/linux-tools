# RTSP Recorder

This tool aims at running a SystemD service, that records video from an IP camera. Coordinates are stored in a config file located at /etc/starwit/rtsp-recorder/env.sh. 

This service is basically just a shell script, that is located [here](rtsp-recorder/recording.sh). SystemD service is defined [here](debian/rtsp-recorder.service).

## How to use

Installation
```bash
apt install ./rtsp-recorder_0.0.1_all.deb
```

Removal
```bash
apt remove ./rtsp-recorder_0.0.1_all.deb
```

If all config files shall be removed, use this command:
```bash
apt purge ./rtsp-recorder_0.0.1_all.deb
```

Configuration
```bash
export USERNAME=username # username for IP camera
export PASSWORD=password # username for IP camera
export CAMERA_URI=hostname # camera ip/hostname
export TARGETDIR=/path/to/folder # where to store video file
```

## How to build APT package

```bash
make build-deb
```