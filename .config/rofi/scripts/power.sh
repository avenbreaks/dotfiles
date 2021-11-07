#!/usr/bin/env sh

# ~/.config/rofi/scripts/power.sh: Run rofi power-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `systemd-logind` or `elogind` already installed.
if [ -x "$(command -v systemctl)" ]; then
    SEATCTL='systemctl'
elif [ -x "$(command -v loginctl)" ]; then
    SEATCTL='loginctl'
else
    # Send fails notification.
    exec "$V_NOTIFIER" -r 82 -i "$LOCK_ICON" '' '<b>systemd-logind</b> or <b>elogind</b> not installed nor running!'
fi

ROFI="rofi -theme themes/sidebar/five-${CHK_ROFI}.rasi"

A='' B='' C='' D='' E=''

MENU="$(printf "${A}\n${B}\n${C}\n${D}\n${E}\n" | ${ROFI} -dmenu -selected-row 2)"

case "$MENU" in
    "$A") exec "${ROFI_SCRIPTS_DIR}/prompt-menu.sh" \
              --yes-command "${SEATCTL} poweroff"   \
              --query '     Poweroff?'
    ;;
    "$B") exec "${ROFI_SCRIPTS_DIR}/prompt-menu.sh" \
              --yes-command "${SEATCTL} reboot"     \
              --query '      Reboot?'
    ;;
    "$C") exec "$LAUNCH_APPS" lockscreen
    ;;
    "$D") [ -z "$("$MUSIC_CONTROLLER" status)" ] || "$MUSIC_CONTROLLER" toggle
          exec "$SEATCTL" suspend
    ;;
    "$E") exec "${ROFI_SCRIPTS_DIR}/prompt-menu.sh"             \
              --yes-command "pkill -KILL -u ${USER:-$(id -nu)}" \
              --query '      Logout?'
    ;;
esac

exit ${?}
