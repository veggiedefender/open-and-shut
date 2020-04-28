#!/usr/bin/env bash

readonly KEYBOARD_DEV=/dev/input/event3

opened_at=$(date +%s%3N)
pkill -f morse_code_close.sh

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
    [-----]=0
    [.----]=1
    [..---]=2
    [...--]=3
    [....-]=4
    [.....]=5
    [-....]=6
    [--...]=7
    [---..]=8
    [----.]=9
    [.-.-.-]=DOT
    [--..--]=COMMA
    [---...]=:
    [..--..]=?
    [.----.]=APOSTROPHE
    [-....-]=MINUS
    [-..-.]=SLASH
    [-.--.]='('
    [-.--.-]=')'
    [.-..-.]='"'
    [-...-]=EQUAL
    [.-.-.]=+
    [.--.-.]=@
)

# Grab environment variables to interact with X
# From https://gist.github.com/AladW/de1c5676d93d05a5a0e1/
pid=$(pgrep -t tty"$(fgconsole)" xinit)
pid=$(pgrep -P "$pid" -n)
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
else
    exit 0
fi

sleep "$letter_pause"
sequence=$(cat /tmp/morse_code_letter)
if [[ ! -v "morse_letters[$sequence]" ]] ; then
    exit 0
fi

if [[ "${morse_letters[$sequence]}" == [A-Z] ]]; then
    evemu-event /dev/input/event3 --type EV_KEY --code KEY_LEFTSHIFT --value 1 --sync
    evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_${morse_letters[$sequence]}" --value 1 --sync
    evemu-event /dev/input/event3 --type EV_KEY --code KEY_LEFTSHIFT --value 0 --sync
elif [[ "${morse_letters[$sequence]}" =~ [A-Z0-9] ]]; then
    evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_${morse_letters[$sequence]}" --value 1 --sync
else
    evemu-event /dev/input/event3 --type EV_KEY --code KEY_LEFTSHIFT --value 1 --sync
    if [[ "${morse_letters[$sequence]}" == ":" ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_SEMICOLON" --value 1 --sync
    elif [[ "${morse_letters[$sequence]}" == "?" ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_SLASH" --value 1 --sync
    elif [[ "${morse_letters[$sequence]}" == '"' ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_APOSTROPHE" --value 1 --sync
    elif [[ "${morse_letters[$sequence]}" == '(' ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_9" --value 1 --sync
    elif [[ "${morse_letters[$sequence]}" == ')' ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_0" --value 1 --sync
    elif [[ "${morse_letters[$sequence]}" == '@' ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_2" --value 1 --sync
    elif [[ "${morse_letters[$sequence]}" == '+' ]]; then
        evemu-event $KEYBOARD_DEV --type EV_KEY --code "KEY_EQUAL" --value 1 --sync
    fi
    evemu-event /dev/input/event3 --type EV_KEY --code KEY_LEFTSHIFT --value 0 --sync
fi

rm /tmp/morse_code_letter

sleep "$space_pause"
xdotool type " "
