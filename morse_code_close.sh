#!/usr/bin/env bash

# If the user closes the lid without opening it again for this duration, then
# suspend the system
suspend_pause=15

closed_at=$(date +%s%3N)
pkill -f morse_code_open.sh

echo "$closed_at" > /tmp/morse_code_close.timestamp

sleep "$suspend_pause"
systemctl suspend
