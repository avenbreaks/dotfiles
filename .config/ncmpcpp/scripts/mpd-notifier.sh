#!/usr/bin/env sh

# ~/.config/ncmpcpp/scripts/mpd-notifier.sh: Run MPD with notification-sender whenever track was changed.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `mpd` and `mpc` already installed.
{ command -v mpd && command -v mpc; } >/dev/null 2>&1 || exit 1

# Alias `mpc` to port 7777.
alias mpc="mpc -p ${MPD_PORT}"

{
    # Kill MPD if already running.
    ! pgrep 'mpd' || mpd --kill || killall -9 mpd
    
    # Run MPD.
    nice -n 1 mpd || mpd || exit ${?}
    
    # Loop `mpc idle`, then send notification.
    while :; do
        OLD_TRACK="$(mpc current)"
        nice -n 19 mpc idle || mpc idle || break
        [ "$OLD_TRACK" = "$(mpc current)" ] || "$MPD_ALBUMART_NOTIFIER"
    done
    
} >/dev/null 2>&1 &

exit ${?}
