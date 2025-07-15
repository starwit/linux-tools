# Wake up devices through Wake-On-LAN over simple web frontend or HTTP
This is a simple no-dependency Python script that exposes two HTTP endpoints while running:

| Endpoint | Desc |
| -------- | ----- |
| `GET /` | Serves a simple HTML button that calls `/trigger_wol` |
| `GET /trigger_wol/{id}` | Sends the magic packet to wake up a local device (using `wakeonlan`) |

## Setup
Run this on a Linux machine if you want to use `wakeonlan`.
- Make sure Python and `wakeonlan` are installed and available on the path
- Add your device to the list `WOL_DEVICES` using an identifier and the MAC address of remote machine (find out with `TARGET_IP=1.2.3.4; ping -c 1 $TARGET_IP > /dev/null && arp -n | grep $TARGET_IP`)
- Run `python3 wol_http_server` (optionally add `--port 1234` to customize server port)
- Access simple webpage on `host:8000`

## Automatic startup (via Systemd)
- Run `install_user_service.sh`
- Enable service\
  `systemctl --user enable wol-http-trigger.service`
- Make systemd user services run without session\
  `loginctl enable-linger`

## Update
- Change devices list in script
- Restart service\
  `systemctl --user restart wol-http-trigger.service`