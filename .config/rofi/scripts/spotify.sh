#!/usr/bin/env sh

# ~/.config/rofi/scripts/spotify.sh: Run rofi spotify-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

ROFI="rofi -theme themes/sidebar/five-${CHK_ROFI}.rasi"

A='' B='' C='' D='' E=''

status="$("$MUSIC_CONTROLLER" status)"
current="$("$MUSIC_CONTROLLER" title)"

[ -z "$status" ] || B=''

active='' urgent='-a 4'

[ -n "$current" ] || current='-'

MENU="$(printf "${A}\n${B}\n${C}\n${D}\n${E}\n" | ${ROFI} -dmenu ${active} ${urgent} -selected-row 1)"

case "$MENU" in
    "$A") exec "$MUSIC_CONTROLLER" prev
    ;;
    "$B") exec "$MUSIC_CONTROLLER" toggle
    ;;
    "$C") exec "$MUSIC_CONTROLLER" stop
    ;;
    "$D") exec "$MUSIC_CONTROLLER" next
    ;;
    "$E") exec "$MUSIC_CONTROLLER" switch
    ;;
esac

exit ${?}
