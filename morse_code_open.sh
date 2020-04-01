#!/usr/bin/env bash

opened_at=$(date +%s%3N)

# Max duration of a dot and dash, in milliseconds
dot_length=250
dash_length=3000

# Duration to pause before typing a letter or space, in seconds
letter_pause=2
space_pause=2

declare -A morse_letters=(
    [.-]=A
    [-...]=B
    [-.-.]=C
    [-..]=D
    [.]=E
    [..-.]=F
    [--.]=G
    [....]=H
    [..]=I
    [.---]=J
    [-.-]=K
    [.-..]=L
    [--]=M
    [-.]=N
    [---]=O
    [.--.]=P
    [--.-]=Q
    [.-.]=R
    [...]=S
    [-]=T
    [..-]=U
    [...-]=V
    [.--]=W
    [-..-]=X
    [-.--]=Y
    [--..]=Z
)

# Grab environment variables to interact with X
# From https://gist.github.com/AladW/de1c5676d93d05a5a0e1/
pid=$(pgrep -t tty$(fgconsole) xinit)
pid=$(pgrep -P $pid -n)
import_environment() {
    (( pid )) && for var; do
        IFS='=' read key val < <(egrep -z "$var" /proc/$pid/environ)

        printf -v "$key" %s "$val"
        [[ ${!key} ]] && export "$key"
    done
}
import_environment XAUTHORITY USER DISPLAY

echo "$opened_at" > /tmp/morse_code_open.timestamp

if [ ! -f /tmp/morse_code_close.timestamp ]; then
    exit 0
fi
closed_at=$(cat /tmp/morse_code_close.timestamp)
elapsed="$((opened_at - closed_at))"

if [ "$elapsed" -lt "$dot_length" ]; then
    printf "%s" "." >> /tmp/morse_code_letter
elif [ "$elapsed" -lt "$dash_length" ]; then
    printf "%s" "-" >> /tmp/morse_code_letter
fi

sleep "$letter_pause"
sequence=$(cat /tmp/morse_code_letter)
xdotool type "${morse_letters[$sequence]}"
rm /tmp/morse_code_letter

sleep "$space_pause"
xdotool type " "
