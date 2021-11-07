#!/usr/bin/env sh

# ~/.config/tint2/executor/network.sh: Get network status for tint2 panel.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `iproute2` and/or `wireless-tools` already installed.
{ command -v iwgetid || command -v ip; } >/dev/null 2>&1 || exec echo 'Install `iproute2` and/or `wireless-tools`!'

# WLAN.
if iwgetid "$INT_WIFI" >/dev/null 2>&1; then
    if [ -n "$(iwgetid "$INT_WIFI" | cut -d\" -f2)" ]; then
        if ip addr show "$INT_WIFI" | grep -Fqo 'inet'; then
            status="$(iwgetid "$INT_WIFI" --raw) @ ${INT_WIFI}"
            icon=''
        else
            status="No IP address @ ${INT_WIFI}"
            icon=''
        fi
    else
        status="Disconnected @ ${INT_WIFI}"
        icon=''
    fi
# LAN.
elif ip link show "$INT_ETH" >/dev/null 2>&1; then
    if ip addr show "$INT_ETH" | grep -Fqo 'inet'; then
        status="$(ip addr show "$INT_ETH" | grep -o 'inet [0-9]*.[0-9]*.[0-9]*.[0-9]' | cut -d' ' -f2) @ ${INT_ETH}"
        icon=''
    else
        status="No IP address @ ${INT_ETH}"
        icon=''
    fi
else
    status="Invalid network interface for \"${INT_ETH}\" and \"${INT_WIFI}\""
    icon=''
fi

case ${1} in
    status) exec echo "$status"
    ;;
    icon)   exec echo "$icon"
    ;;
esac

exit ${?}
