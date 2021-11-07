#!/usr/bin/env sh

# ~/.config/rofi/scripts/brightness.sh: Run rofi brightness-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

ROFI="rofi -theme themes/sidebar/three-${CHK_ROFI}.rasi"

A='' B='' C=''

MENU="$(printf "${A}\n${B}\n${C}\n" | ${ROFI} -dmenu -selected-row 1)"

case "$MENU" in
    "$A") exec "$CHANGE_BRIGHTNESS" up
    ;;
    "$C") exec "$CHANGE_BRIGHTNESS" down
    ;;
    "$B") exec "$CHANGE_BRIGHTNESS" optimal
    ;;
esac

exit ${?}
