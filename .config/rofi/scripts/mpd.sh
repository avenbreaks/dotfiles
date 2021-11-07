#!/usr/bin/env sh

# ~/.config/rofi/scripts/mpd.sh: Run rofi mpd-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

ROFI="rofi -theme themes/sidebar/six-${CHK_ROFI}.rasi"

A='' B='' C='' D='' E='' F=''

status="$("$MUSIC_CONTROLLER" status)"
current="$("$MUSIC_CONTROLLER" title)"

[ -z "$status" ] || B=''

active='' urgent=''

if mpc -p "$MPD_PORT" status | grep -Fqo 'single: on'; then
    active='-a 4'
elif mpc -p "$MPD_PORT" status | grep -Fqo 'single: off'; then
    urgent='-u 4'
else
    E=''
fi

[ -n "$urgent" ] && urgent="${urgent},5" || urgent='-u 5'

[ -n "$current" ] || current='-'

MENU="$(printf "${A}\n${B}\n${C}\n${D}\n${E}\n${F}\n" | ${ROFI} -dmenu ${active} ${urgent} -selected-row 1)"

case "$MENU" in
    "$A") exec "$MUSIC_CONTROLLER" prev
    ;;
    "$B") exec "$MUSIC_CONTROLLER" toggle
    ;;
    "$C") exec "$MUSIC_CONTROLLER" stop
    ;;
    "$D") exec "$MUSIC_CONTROLLER" next
    ;;
    "$E") exec mpc -p "$MPD_PORT" -q single
    ;;
    "$F") exec "$MUSIC_CONTROLLER" switch
    ;;
esac

exit ${?}
