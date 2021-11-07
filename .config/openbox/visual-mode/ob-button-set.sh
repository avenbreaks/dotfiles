#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/ob-button-set.sh: Setup Openbox button-specific or toggle decorations.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

case ${1} in
    swap)  # Swap Openbox button location.
           if [ "$CHK_OB_BUTTON_LOC" != 'left' ]; then
               sed -i '/<titleLayout>/s|>.*<|>CIML<|' "$OB_CONFIG"
               # Write current Openbox button location to configuration.
               sed -i "/ob_button_location$([ -z "$CHK_MINMOD" ] || echo '.minimal') /s|\".*\"|\"left\"|" "$THEME_FILE"
           elif [ "$CHK_OB_BUTTON_LOC" != 'right' ]; then
               sed -i '/<titleLayout>/s|>.*<|>LIMC<|' "$OB_CONFIG"
               # Write current Openbox button location to configuration.
               sed -i "/ob_button_location$([ -z "$CHK_MINMOD" ] || echo '.minimal') /s|\".*\"|\"right\"|" "$THEME_FILE"
           fi
           # Reconfigure Openbox.
           exec openbox --reconfigure
    ;;
    decor) # Toggle Openbox decorations.
           DECOR_LINE="$(($(cat -n "$OB_CONFIG" | grep -F '<application class="*" type="normal">' | grep -oE '[0-9]+')+1))"
           if cat -n "$OB_CONFIG" | grep -Fqo "${DECOR_LINE}	        <decor>yes</decor>"; then
               sed -i "${DECOR_LINE}s|<decor>.*</decor>|<decor>no</decor>|" "$OB_CONFIG"
           elif cat -n "$OB_CONFIG" | grep -Fqo "${DECOR_LINE}	        <decor>no</decor>"; then
               sed -i "${DECOR_LINE}s|<decor>.*</decor>|<decor>yes</decor>|" "$OB_CONFIG"
           fi
           # Reconfigure and restart Openbox.
           exec openbox --reconfigure --restart
    ;;
    *)     # ANSI color codes.
           RB='\033[0m\033[5;31m' BB='\033[0m\033[5;34m' W='\033[1;37m' NC='\033[0m' m='\033[0;35m' g='\033[0;32m'
           # Parse modes in order to capitalize words.
           GUESS_MODE="$([ -z "$CHK_MINMOD" ] || echo 'MINIMAL ')$(echo "$CHK_VISMOD" | tr '[:lower:]' '[:upper:]')"
           # Select Openbox button-style per modes.
           printf "${W}AVAILABLE OPENBOX BUTTON-STYLE FOR ${GUESS_MODE} THEME:${NC}\n"
           for BUTTON in "$OB_BUTTON_DIR"/*; do
               [ -d "$BUTTON" ] || exit ${?}
               N=$((N+1)); printf "${m}[${NC}${N}${m}]$([ "${BUTTON##*/}" = "$CHK_OB_BUTTON_STYLE" ] && echo "$g" || \
               echo "$NC" ) ${BUTTON##*/}${NC}\n"
               eval "BUTTON${N}=\$BUTTON"
           done
           printf "${W}ENTER INDEX-NUMBER\n${RB}>${m}>${BB}>${NC} "
           read -r NUM; NUM="$(echo "$NUM" | tr -dc '[:digit:]')"
           if [ "${NUM:-0}" -eq 0 ] || [ "${NUM:-0}" -gt "$N" ]; then
               printf "${RB}WRONG SELECTION!${NC}\n" >&2
               exit 1
           else
               eval "BUTTON=\$BUTTON${NUM}"
               # Install current Openbox button.
               install -t "$({ [ "$CHK_VISMOD" = 'mechanical' ] && echo "$MECH_BUTTON_DIR"; } || \
               { [ "$CHK_VISMOD" = 'eyecandy' ] && echo "$EYEC_BUTTON_DIR"; })"/ "$BUTTON"/*.'xbm'
               # Reconfigure Openbox.
               openbox --reconfigure
               # Write current Openbox button-style to configuration.
               sed -i "/ob_button_style$([ -z "$CHK_MINMOD" ] || echo '.minimal') /s|\".*\"|\"${BUTTON##*/}\"|" "$THEME_FILE"
           fi
    ;;
esac

exit ${?}
