#!/usr/bin/env sh

# ~/.config/tint2/executor/volume.sh: Change pulseaudio volume through `amixer` for tint2 panel.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `amixer` already installed.
command -v amixer >/dev/null 2>&1 || exec echo 'Install `alsa-utils`!'

VOLUME="$(amixer get Master | grep -m1 -o '[0-9]*%')"

icon()
{
    if [ "${VOLUME%%%}" -eq 0 ]; then
        icon=''
    elif [ "${VOLUME%%%}" -lt 30 ]; then
        icon=''
    elif [ "${VOLUME%%%}" -lt 70 ]; then
        icon=''
    else
        icon=''
    fi
    
    echo "$icon"
}

case ${1} in
    percent) amixer get Master | grep -Fqo 'off' && echo 'Muted' || echo "$VOLUME"
    ;;
    icon)    amixer get Master | grep -Fqo 'off' && echo '' || icon
    ;;
    up)      amixer set Master on -q
             amixer sset Master "${AUDIO_STEPS:-5}%+" -q
    ;;
    down)    amixer set Master on -q
             amixer sset Master "${AUDIO_STEPS:-5}%-" -q
    ;;
    mute)    amixer set Master 1+ toggle -q
    ;;
esac

exit ${?}
