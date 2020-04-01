#!/usr/bin/env bash

grep -q close /proc/acpi/button/lid/*/state
if [ $? = 0 ]; then
    /etc/acpi/morse_code_close.sh & disown
fi
grep -q open /proc/acpi/button/lid/*/state
if [ $? = 0 ]; then
    /etc/acpi/morse_code_open.sh & disown
fi
