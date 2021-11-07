#!/usr/bin/env sh

# ~/.config/tint2/executor/volume.sh: Change pulseaudio volume through `amixer` for tint2 panel.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `amixer` already installed.
command -v amixer >/dev/null 2>&1 || exec echo 'Install `alsa-utils`!'

VOLUME="$(amixer get Master | grep -o '[0-9]*%' | sed 1q)"

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
    
    exec echo "$icon"
}

case ${1} in
    percent) if amixer get Master | grep -Fqo 'off'; then
                 exec echo 'Muted'
             else
                 exec echo "$VOLUME"
             fi
    ;;
    icon)    if amixer get Master | grep -Fqo 'off'; then
                 exec echo ""
             else
                 icon
             fi
    ;;
    up)      amixer set Master on -q
             exec amixer sset Master "${AUDIO_STEPS:-5}%+" -q
    ;;
    down)    amixer set Master on -q
             exec amixer sset Master "${AUDIO_STEPS:-5}%-" -q
    ;;
    mute)    exec amixer set Master 1+ toggle -q
    ;;
esac

exit ${?}
