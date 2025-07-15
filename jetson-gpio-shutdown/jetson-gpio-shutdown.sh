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
last_value=""
while true; do
    value=$(gpioget gpiochip0 "$GPIO_PIN")
    if [ "$value" -eq 1 ]; then
        counter=$((counter + 1))
        if [ "$last_value" != "1" ]; then
            echo "GPIO $GPIO_PIN is high, shutting down in $TIMEOUT_SECONDS seconds."
        fi
    else
        if [ "$last_value" != "0" ]; then
            echo "GPIO $GPIO_PIN is low, resetting timeout."
        fi
        counter=0
    fi
    last_value="$value"

    if [ "$counter" -ge "$TIMEOUT_SECONDS" ]; then
        echo "GPIO $GPIO_PIN high for $TIMEOUT_SECONDS seconds, shutting down."
        shutdown -h now
        exit 0
    fi

    sleep 1
done
