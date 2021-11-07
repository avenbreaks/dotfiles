#!/usr/bin/env sh

# ~/.config/rofi/scripts/screenshot.sh: Run rofi screenshot-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

ROFI="rofi -theme themes/sidebar/three-${CHK_ROFI}.rasi"

A='' B='' C=''

MENU="$(printf "${A}\n${B}\n${C}\n" | ${ROFI} -dmenu -selected-row 1)"

case "$MENU" in
    "$A") exec "$SCREENSHOT_NOW" delay
    ;;
    "$B") exec "$SCREENSHOT_DRAW"
    ;;
    "$C") exec "$SCREENSHOT_TIMER"
    ;;
esac

exit ${?}
