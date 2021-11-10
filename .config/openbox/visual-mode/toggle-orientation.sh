#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/toggle-orientation.sh: Toggle user interface orientation.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution, then restore UTF-8 before launching apps.
OLD_LANG="$LANG"; export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure current mode is not minimal mode.
[ -z "$CHK_MINMOD" ] || exit ${?}

# Kill tint2 panel and dunst notification daemon.
killall tint2 dunst >/dev/null 2>&1

case ${1} in
    lrtb) # Toggle left-right or top-bottom panel orientation.
          if [ "$CHK_PANEL_ORT" = 'vertical' ]; then
              if [ "$CHK_PANEL_ORT_V" != 'left' ]; then
                  # Write left vertical panel orientation to configuration.
                  sed -i '/vertical_panel /s|".*"|"left"|' "$MODE_FILE"
                  # Set Openbox margin, dunst notification daemon, and rofi orientation.
                  "${VISMOD_DIR}/margin-dunst-rofi.sh" v_left
                  sed -si '/panel_position/s|= center .* vertical|= center left vertical|' "$TINT2_DIR"/*-"${CHK_PANEL_ORT}.tint2rc"
              elif [ "$CHK_PANEL_ORT_V" != 'right' ]; then
                  # Write right vertical panel orientation to configuration.
                  sed -i '/vertical_panel /s|".*"|"right"|' "$MODE_FILE"
                  # Set Openbox margin, dunst notification daemon, and rofi orientation.
                  "${VISMOD_DIR}/margin-dunst-rofi.sh" v_right
                  sed -si '/panel_position/s|= center .* vertical|= center right vertical|' "$TINT2_DIR"/*-"${CHK_PANEL_ORT}.tint2rc"
              fi
          elif [ "$CHK_PANEL_ORT" = 'horizontal' ]; then
              if [ "$CHK_PANEL_ORT_H" != 'bottom' ]; then
                  # Write bottom horizontal panel orientation to configuration.
                  sed -i '/horizontal_panel /s|".*"|"bottom"|' "$MODE_FILE"
                  # Set Openbox margin, dunst notification daemon, and rofi orientation.
                  "${VISMOD_DIR}/margin-dunst-rofi.sh" h_bottom
                  sed -si '/panel_position/s|= .* center horizontal|= bottom center horizontal|' "$TINT2_DIR"/*-"${CHK_PANEL_ORT}.tint2rc"
              elif [ "$CHK_PANEL_ORT_H" != 'top' ]; then
                  # Write top horizontal panel orientation to configuration.
                  sed -i '/horizontal_panel /s|".*"|"top"|' "$MODE_FILE"
                  # Set Openbox margin, dunst notification daemon, and rofi orientation.
                  "${VISMOD_DIR}/margin-dunst-rofi.sh" h_top
                  sed -si '/panel_position/s|= .* center horizontal|= top center horizontal|' "$TINT2_DIR"/*-"${CHK_PANEL_ORT}.tint2rc"
              fi
          fi
    ;;
    ort)  # Toggle vertical-horizontal panel orientation.
          if [ "$CHK_PANEL_ORT" != 'vertical' ]; then
              # Write vertical panel orientation to configuration.
              sed -e "/vertical_panel /s|\".*\"|\"${CHK_PANEL_ORT_V}\"|" \
                  -e '/panel_orientation /s|".*"|"vertical"|'            \
                  -i "$MODE_FILE"
              # Set Openbox margin, dunst notification daemon, and rofi orientation.
              "${VISMOD_DIR}/margin-dunst-rofi.sh" v_${CHK_PANEL_ORT_V}
              sed -si "/panel_position/s|= center .* vertical|= center ${CHK_PANEL_ORT_V} vertical|" "$TINT2_DIR"/*-"${CHK_PANEL_ORT}.tint2rc"
          elif [ "$CHK_PANEL_ORT" != 'horizontal' ]; then
              # Write horizontal panel orientation to configuration.
              sed -e "/horizontal_panel /s|\".*\"|\"${CHK_PANEL_ORT_H}\"|" \
                  -e '/panel_orientation /s|".*"|"horizontal"|'            \
                  -i "$MODE_FILE"
              # Set Openbox margin, dunst notification daemon, and rofi orientation.
              "${VISMOD_DIR}/margin-dunst-rofi.sh" h_${CHK_PANEL_ORT_H}
              sed -si "/panel_position/s|= center .* horizontal|= center ${CHK_PANEL_ORT_V} horizontal|" "$TINT2_DIR"/*-"${CHK_PANEL_ORT}.tint2rc"
          fi
    ;;
esac

# Reconfigure Openbox then partially restart user interface.
openbox --reconfigure
unset LC_ALL; export LANG="$OLD_LANG"
exec "${VISMOD_DIR}/UI.sh" partially >/dev/null 2>&1

exit ${?}
