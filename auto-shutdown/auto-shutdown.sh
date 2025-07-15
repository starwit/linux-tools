#!/bin/bash

# This script checks if certain conditions are met for automatically shutting down the system
# Conditions: 15 min load below threshold, no active users, no tmux sessions
# This is meant to be run through a systemd timer

# Set the threshold for the system load
LOAD_THRESHOLD=0.5

# Get the system load
LOAD_15M=$(uptime | sed -r 's/.*([0-9]+[,\.][0-9]+)$/\1/' | tr ',' '.')

# Get the number of users
ACTIVE_USERS=$(w -h | wc -l)
TMUX_COUNT=$(ps -e -o comm | grep tmux | wc -l)

echo "System load: $LOAD_15M, Active users: $ACTIVE_USERS, Active tmux processes $TMUX_COUNT"

# Check if the number of users is 0 and the LOAD_15M is below the threshold
if [ "$(echo "$LOAD_15M < $LOAD_THRESHOLD" | bc -l)" -eq 1 ] && [ "$ACTIVE_USERS" -eq 0 ] && [ "$TMUX_COUNT" -eq 0 ]; then
    echo "Shutting down the system"
    shutdown -h now
else
    echo "Not shutting down"
fi
