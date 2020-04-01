#!/usr/bin/env bash

closed_at=$(date +%s%3N)
pkill -f morse_code_open.sh

echo "$closed_at" > /tmp/morse_code_close.timestamp
