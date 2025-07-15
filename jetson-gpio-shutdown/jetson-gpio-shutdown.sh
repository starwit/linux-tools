#!/bin/bash

# Load config file if present
CONFIG_FILE="${JETSON_GPIO_SHUTDOWN_CONF:-/etc/jetson-gpio-shutdown.conf}"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
fi

# Configurable parameters
GPIO_PIN=${GPIO_PIN:-105}           # Default GPIO pin (change as needed)
TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-30}  # Default timeout in seconds

# Main loop
counter=0
while true; do
    value=$(gpioget gpiochip0 "$GPIO_PIN")
    if [ "$value" -eq 0 ]; then
        counter=$((counter + 1))
        echo "GPIO $GPIO_PIN is high, counter: $counter"
    else
        counter=0
        echo "GPIO $GPIO_PIN is low, resetting counter."
    fi

    if [ "$counter" -ge "$TIMEOUT_SECONDS" ]; then
        echo "GPIO $GPIO_PIN high for $TIMEOUT_SECONDS seconds, shutting down."
        shutdown -h now
        exit 0
    fi

    sleep 1
done
