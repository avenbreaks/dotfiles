#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/toggle-mode.sh: Toggle visual mode, minimal mode, or restart user interface.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution, then restore UTF-8 before launching apps.
OLD_LANG="$LANG"; export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

start_ui()
{
    # Write current modes to configuration.
    sed -e "/visual_mode /s|\".*\"|\"${1}\"|"  \
        -e "/minimal_mode /s|\".*\"|\"${2}\"|" \
        -i "$MODE_FILE"
    
    # Setup theme per modes then start user interface.
    "${VISMOD_DIR}/${1}/theme$([ -z "${2}" ] || echo ".${2}").sh"
    "${VISMOD_DIR}/UI.sh" "${2}"
    
    # Send successful notification.
    notify-send.sh -u low -r 80 -i "${GLADIENT_ICON_DIR}/${1}$([ -z "${2}" ] ||   \
    echo ".${2}").png" "$([ -n "${2}" ] && echo 'Minimal' || echo 'Visual') Mode" \
    "$(echo "${1}" | sed 's|.*|\u&|') Theme"
}

{
    # Kill tint2 panel and dunst notification daemon.
    killall tint2 dunst
    
    unset LC_ALL; export LANG="$OLD_LANG"
    
    case ${1} in
        minimal) # Switch minimal mode.
                 start_ui "$CHK_VISMOD" "$([ -n "$CHK_MINMOD" ] || echo 'minimal')"
        ;;
        just_ui) # Load X resource database.
                 xrdb "$XRESOURCES_CONFIG" &
                 # Only start user interface.
                 "${VISMOD_DIR}/UI.sh" "$CHK_MINMOD"
        ;;
        *)       # Kill all user's tray.
                 for KILL_TRAY in $(echo "$CHK_TRAY"); do
                     eval "killall -9 \"$KILL_TRAY\" >/dev/null 2>&1 &"
                 done
                 # Switch visual mode / theme.
                 start_ui "$({ [ "$CHK_VISMOD" != 'mechanical' ] && echo 'mechanical'; } || \
                 { [ "$CHK_VISMOD" != 'eyecandy' ] && echo 'eyecandy'; })" "$CHK_MINMOD"
                 # Run all user's tray.
                 for EXEC_TRAY in $(echo "$CHK_TRAY"); do
                     pgrep "$EXEC_TRAY" >/dev/null 2>&1  || \
                     [ -x "$(command -v "$EXEC_TRAY")" ] && \
                     eval "\"$EXEC_TRAY\" >/dev/null 2>&1 &"
                 done
        ;;
    esac

} >/dev/null 2>&1

exit ${?}
