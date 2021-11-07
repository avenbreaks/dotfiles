#!/usr/bin/env sh

# ~/.scripts/change-brightness.sh: Change brightness through `brightnessctl`.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `brightnessctl` already installed.
command -v brightnessctl >/dev/null 2>&1 || exec "$V_NOTIFIER" -u low -r 71 'Install `brightnessctl`!'

notify()
{
    BRIGHTNESS="$(brightnessctl get -P)"
    
    if [ "$BRIGHTNESS" -eq 0 ]; then
        icon='notification-display-brightness-off'
    elif [ "$BRIGHTNESS" -lt 10 ]; then
        icon='notification-display-brightness-low'
    elif [ "$BRIGHTNESS" -lt 70 ]; then
        icon='notification-display-brightness-medium'
    elif [ "$BRIGHTNESS" -lt 100 ]; then
        icon='notification-display-brightness-high'
    else
        icon='notification-display-brightness-full'
    fi
    
    exec "$V_NOTIFIER" -r 71 -t 750 -i "$icon" "${BRIGHTNESS} " -h "int:value:${BRIGHTNESS}"
}

case ${1} in
    up)      brightnessctl set "${BRIGHTNESS_STEPS:-5}%+" -q
    ;;
    down)    brightnessctl set "${BRIGHTNESS_STEPS:-5}%-" -q
    ;;
    optimal) brightnessctl set 25% -q
    ;;
esac

notify

exit ${?}
