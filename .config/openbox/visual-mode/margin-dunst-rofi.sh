#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/margin-dunst-rofi.sh: Adjust Openbox margin, dunst notification daemon, and rofi orientation.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Default openbox margin.
OB_MARGIN='10'

# Write rofi orientation based on current panel orientation to configuration.
sed -i "/rofi_sidebar /s|\".*\"|\"${CHK_PANEL_ORT}\"|" "$THEME_FILE"

case ${1} in
    v_left)   sed -e '/geometry/s|= ".*"|= "350x6-19+52"|' \
                  -si "${DUNST_DIR}/mechanical.dunstrc"    \
                      "${DUNST_DIR}/eyecandy.dunstrc"
              
              sed -e '/x-offset/s|:.*;|: -1.4%;|' \
                  -e '/location/s|:.*;|: east;|'  \
                  -e '/anchor/s|:.*;|: east;|'    \
                  -si "$ROFI_SIDEBAR_DIR"/*-'vertical.rasi'
              
              sed -e "/<top>/s|>.*<|>${OB_MARGIN}<|"       \
                  -e "/<bottom>/s|>.*<|>${OB_MARGIN}<|"    \
                  -e "/<left>/s|>.*<|>$((45+OB_MARGIN))<|" \
                  -e "/<right>/s|>.*<|>${OB_MARGIN}<|"     \
                  -i "$OB_CONFIG"
    ;;
    v_right)  sed -e '/geometry/s|= ".*"|= "350x6+19+52"|' \
                  -si "${DUNST_DIR}/mechanical.dunstrc"    \
                      "${DUNST_DIR}/eyecandy.dunstrc"
              
              sed -e '/x-offset/s|:.*;|: 1.4%;|' \
                  -e '/location/s|:.*;|: west;|' \
                  -e '/anchor/s|:.*;|: west;|'   \
                  -si "$ROFI_SIDEBAR_DIR"/*-'vertical.rasi'
              
              sed -e "/<top>/s|>.*<|>${OB_MARGIN}<|"        \
                  -e "/<bottom>/s|>.*<|>${OB_MARGIN}<|"     \
                  -e "/<left>/s|>.*<|>${OB_MARGIN}<|"       \
                  -e "/<right>/s|>.*<|>$((45+OB_MARGIN))<|" \
                  -i "$OB_CONFIG"
    ;;
    h_top)    sed -e '/geometry/s|= ".*"|= "350x6+19+65"|' \
                  -si "${DUNST_DIR}/mechanical.dunstrc"    \
                      "${DUNST_DIR}/eyecandy.dunstrc"
              
              sed -e '/y-offset/s|:.*;|: -3%;|'   \
                  -e '/location/s|:.*;|: south;|' \
                  -e '/anchor/s|:.*;|: south;|'   \
                  -si "$ROFI_SIDEBAR_DIR"/*-'horizontal.rasi'
              
              sed -e "/<top>/s|>.*<|>$((45+OB_MARGIN))<|" \
                  -e "/<bottom>/s|>.*<|>${OB_MARGIN}<|"   \
                  -e "/<left>/s|>.*<|>${OB_MARGIN}<|"     \
                  -e "/<right>/s|>.*<|>${OB_MARGIN}<|"    \
                  -i "$OB_CONFIG"
    ;;
    h_bottom) sed -e '/geometry/s|= ".*"|= "350x6-19+52"|' \
                  -si "${DUNST_DIR}/mechanical.dunstrc"    \
                      "${DUNST_DIR}/eyecandy.dunstrc"
              
              sed -e '/y-offset/s|:.*;|: 6.9%;|'  \
                  -e '/location/s|:.*;|: north;|' \
                  -e '/anchor/s|:.*;|: north;|'   \
                  -si "$ROFI_SIDEBAR_DIR"/*-'horizontal.rasi'
              
              sed -e "/<top>/s|>.*<|>${OB_MARGIN}<|"         \
                  -e "/<bottom>/s|>.*<|>$((45+OB_MARGIN))<|" \
                  -e "/<left>/s|>.*<|>${OB_MARGIN}<|"        \
                  -e "/<right>/s|>.*<|>${OB_MARGIN}<|"       \
                  -i "$OB_CONFIG"
    ;;
    minimal)  sed -e "/<top>/s|>.*<|>$((30+OB_MARGIN))<|" \
                  -e "/<bottom>/s|>.*<|>${OB_MARGIN}<|"   \
                  -e "/<left>/s|>.*<|>${OB_MARGIN}<|"     \
                  -e "/<right>/s|>.*<|>${OB_MARGIN}<|"    \
                  -i "$OB_CONFIG"
    ;;
esac

exit ${?}
