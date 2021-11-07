#!/usr/bin/env sh

# ~/.scripts/change-volume.sh: Change pulseaudio volume through `amixer`.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `amixer` already installed.
command -v amixer >/dev/null 2>&1 || exec "$V_NOTIFIER" -u low -r 72 'Install `alsa-utils`!'

notify()
{
    VOLUME="$(amixer get Master | grep -o '[0-9]*%' | sed 1q)"
    
    if [ "${VOLUME%%%}" -eq 0 ]; then
        icon='notification-audio-volume-muted'
    elif [ "${VOLUME%%%}" -lt 30 ]; then
        icon='notification-audio-volume-low'
    elif [ "${VOLUME%%%}" -lt 70 ]; then
        icon='notification-audio-volume-medium'
    else
        icon='notification-audio-volume-high'
    fi
    
    exec "$V_NOTIFIER" -r 72 -t 750 -i "$icon" "${VOLUME%%%} " -h "int:value:${VOLUME%%%}"
}

case ${1} in
    up)   amixer set Master on -q
          amixer sset Master "${AUDIO_STEPS:-5}%+" -q
    ;;
    down) amixer set Master on -q
          amixer sset Master "${AUDIO_STEPS:-5}%-" -q
    ;;
    mute) amixer set Master 1+ toggle -q
          ! amixer get Master | grep -Fqo 'off' \
          || exec "$V_NOTIFIER" -r 72 -t 750 -i 'notification-audio-volume-muted' 'Muted '
    ;;
esac

notify

exit ${?}
