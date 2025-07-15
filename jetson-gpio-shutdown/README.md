# Automatic Jetson GPIO-triggered shutdown
This script (and corresponding systemd service that automatically starts on system boot) shuts down the device if a signal to one of the digital inputs (DI1-DI4, configurable) has not been detected (i.e. it is `0`) for a configurable amount of time.
The script runs in a loop and checks the input once a second.