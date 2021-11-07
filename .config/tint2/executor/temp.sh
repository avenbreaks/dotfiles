#!/usr/bin/env sh

# ~/.config/tint2/executor/temp.sh: Get CPU/Mainboard temperature for tint2 panel.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

LINUX_SYS='/sys/devices/virtual/thermal'

if [ -d "${LINUX_SYS}/${TEMP_DEV}" ]; then
    exec echo "$(($([ -n "$BASH" ] && eval "<\"${LINUX_SYS}/${TEMP_DEV}/temp\"" || \
    cat "${LINUX_SYS}/${TEMP_DEV}/temp")/1000))˚C"
elif [ ! -d "$LINUX_SYS" ]; then
    exec echo "${LINUX_SYS} is an invalid path!"
else
    exec echo "${TEMP_DEV} not found!"
fi

exit ${?}
