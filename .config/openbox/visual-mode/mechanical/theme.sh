#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/mechanical/theme.sh: Setup non-minimal mechanical theme.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

partially()
{
    # Set openbox menu color from "~/.joyful_desktop".
    sed -e "/menu.items.active.text.color/s|:.*|: ${MECH_OB_MENU_ITM}|" \
        -e "/menu.title.text.color/s|:.*|: ${MECH_OB_MENU_TTL}|"        \
        -i "${MECH_BUTTON_DIR}/themerc"
    # Set rofi accent color from "~/.joyful_desktop".
    sed -i "/accent/s|:.*;|:           ${MECH_ROFI_ACCENT};|" "${ROFI_COLORSCHEMES_DIR}/fullscreen-dark.rasi"
    sed -e "/foreground/s|:.*;|:       ${MECH_ROFI_FRGRND};|" \
        -e "/accent/s|:.*;|:           ${MECH_ROFI_ACCENT};|" \
        -i "${ROFI_COLORSCHEMES_DIR}/sidebar-dark.rasi"
}

apply_all()
{    
    # Set GTK and Icon themes.
    sed -e '/gtk-icon-theme-name/s|=".*"|="Papirus-Dark-Custom"|' \
        -e '/gtk-theme-name/s|=".*"|="Fleon"|'                    \
        -i "$GTK2_CONFIG"
    sed -e '/gtk-icon-theme-name/s|=.*|=Papirus-Dark-Custom|' \
        -e '/gtk-theme-name/s|=.*|=Fleon|'                    \
        -i "$GTK3_CONFIG"
    
    # Set xsettingsd for GTK+ live reload.
    if [ -x "$(command -v xsettingsd)" ]; then
        if [ -f "$XSETTINGSD_CONFIG" ]; then
            sed -e '/Net\/IconThemeName /s|".*"|"Papirus-Dark-Custom"|' \
                -e '/Net\/ThemeName /s|".*"|"Fleon"|'                   \
                -i "$XSETTINGSD_CONFIG"
            eval "sleep .07s && xsettingsd >/dev/null 2>&1 &"
            eval "sleep 1.3s && killall -9 xsettingsd >/dev/null 2>&1 &"
        fi
    fi
    
    # Set rofi color schemes.
    sed -i '/@import/s|colorschemes/.*.rasi|colorschemes/fullscreen-dark.rasi|' "$ROFI_FULLSCREEN_CONFIG"
    sed -i '/@import/s|colorschemes/.*.rasi|colorschemes/sidebar-dark.rasi|' "$ROFI_SIDEBAR_CONFIG"
    
    # Set Openbox margin, dunst notification daemon, and rofi orientation.
    if [ "$CHK_PANEL_ORT" = 'vertical' ]; then
        # Write vertical panel orientation to configuration.
        sed -i "/vertical_panel /s|\".*\"|\"${CHK_PANEL_ORT_V}\"|" "$MODE_FILE"
        "${VISMOD_DIR}/margin-dunst-rofi.sh" v_${CHK_PANEL_ORT_V}
    elif [ "$CHK_PANEL_ORT" = 'horizontal' ]; then
        # Write horizontal panel orientation to configuration.
        sed -i "/horizontal_panel /s|\".*\"|\"${CHK_PANEL_ORT_H}\"|" "$MODE_FILE"
        "${VISMOD_DIR}/margin-dunst-rofi.sh" h_${CHK_PANEL_ORT_H}
    fi
    # Reconfigure Openbox.
    openbox --reconfigure
    
    # Set Openbox button location.
    if [ "$CHK_OB_BUTTON_LOC" = 'left' ]; then
        sed -i '/<titleLayout>/s|>.*<|>CIML<|' "$OB_CONFIG"
    elif [ "$CHK_OB_BUTTON_LOC" = 'right' ]; then
        sed -i '/<titleLayout>/s|>.*<|>LIMC<|' "$OB_CONFIG"
    fi
    
    # Install and set Openbox button-style and theme.
    install -t "$MECH_BUTTON_DIR"/ "${OB_BUTTON_DIR}/${CHK_OB_BUTTON_STYLE}"/*.'xbm'
    THEME_LINE="$(grep -m1 -no '<name>.*</name>' "$OB_CONFIG" | grep -oE '[0-9]+')"
    sed -i "${THEME_LINE}s|<name>.*</name>|<name>Fleon</name>|" "$OB_CONFIG"
}

case ${1} in
    partially) partially
    ;;
    *)         apply_all
    ;;
esac

# Reconfigure Openbox.
exec openbox --reconfigure

exit ${?}
