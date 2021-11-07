#!/usr/bin/env sh

# ~/.config/ncmpcpp/launch.sh: Ncmpcpp launcher with triple options.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution, then restore UTF-8 before launching ncmpcpp.
OLD_LANG="$LANG"; export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

MUSIC_PLAYER="$("$LAUNCH_APPS" -g music_player)"

if [ "$MUSIC_PLAYER" = 'mpd' ]; then
    {
        unset LC_ALL; export LANG="$OLD_LANG"
        case ${1} in
            album-art)        ! command -v urxvt || exec urxvt -g 84x13 -e ncmpcpp -c "${NCMPCPP_DIR}/album-art.config"
            ;;
            single.album-art) ! command -v urxvt || exec urxvt -g 47x18 -e ncmpcpp -c "${NCMPCPP_DIR}/single.album-art.config"
            ;;
            *)                exec "$LAUNCH_APPS" terminal -e ncmpcpp -c "${NCMPCPP_DIR}/main.config"
            ;;
        esac
        
    } >/dev/null 2>&1 &
else
    # Send fails notification.
    exec notify-send.sh -u low -r 77 -i "$MUSIC_ICON" 'Music Player' "Currently use <u>$("$LAUNCH_APPS" -g music_player)</u>"
fi

exit ${?}
