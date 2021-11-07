#!/usr/bin/env sh

# ~/.scripts/music-controller.sh: Control music player which only supports mpd (`mpc`) and spotify (`playerctl`).
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

MUSIC_PLAYER="$("$LAUNCH_APPS" -g music_player)"

{
    if [ "$MUSIC_PLAYER" = 'mpd' ]; then
        prev="mpc -p ${MPD_PORT} -q prev"
        next="mpc -p ${MPD_PORT} -q next"
        stop="mpc -p ${MPD_PORT} -q stop"
        togg="mpc -p ${MPD_PORT} -q toggle"
        stat="$(mpc -p "$MPD_PORT" status | grep -Fio 'playing')"
        titl="$(mpc -p "$MPD_PORT" --format '[%title%|%file%]' current)"
    elif [ "$MUSIC_PLAYER" = 'spotify' ]; then
        prev='playerctl -p spotify previous'
        next='playerctl -p spotify next'
        stop='playerctl -p spotify stop'
        togg='playerctl -p spotify play-pause'
        stat="$(playerctl -p spotify status | grep -Fio 'playing')"
        titl="$(playerctl -p spotify metadata -f '{{title}}')"
    else
        prev='' togg='' stop='' next='' stat=''
        titl="There's no mpd or spotify installed"
    fi
    
} 2>/dev/null

case ${1} in
    icon)   [ -n "$stat" ] && echo '' || echo ''
    ;;
    prev)   ${prev}
    ;;
    toggle) ${togg}
    ;;
    stop)   ${stop}
    ;;
    next)   ${next}
    ;;
    status) echo "$stat"
    ;;
    title)  echo "$titl"
    ;;
    switch) # Toggle pause if currently playing a song.
            [ -z "$stat" ] || ${togg}
            # Switch music player between mpd and spotify.
            if [ "$MUSIC_PLAYER" != 'mpd' ]; then
                sed -i '/music_player /s|".*"|"mpd"|' "$LIST_APPS_DB"
            elif [ "$MUSIC_PLAYER" != 'spotify' ]; then
                sed -i '/music_player /s|".*"|"spotify"|' "$LIST_APPS_DB"
            fi
            # Send successful notification.
            exec notify-send.sh -u low -r 73 -i "$MUSIC_ICON" 'Music Player' "Switched to <u>$("$LAUNCH_APPS" -g music_player)</u>"
    ;;
esac

exit ${?}
