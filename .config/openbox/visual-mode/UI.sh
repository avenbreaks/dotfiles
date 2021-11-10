#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/UI.sh: Start user interface.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution, then restore UTF-8 before launching apps.
OLD_LANG="$LANG"; export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# ? Mode variables.
if [ "$CHK_VISMOD" = 'mechanical' ]; then
    PANEL_C1="$MECH_TINT2_GRAD1"
    PANEL_C2="$MECH_TINT2_GRAD2"
    PANEL_SB="$MECH_START_BUTTON"
    if [ -n "$CHK_MINMOD" ]; then
        NOTIFYD_FG="$MECH_MIN_DUNST_SMMRY"
        NOTIFYD_PB="$MECH_MIN_DUNST_PRGBR"
    else
        NOTIFYD_FG="$MECH_DUNST_SMMRY"
        NOTIFYD_PB="$MECH_DUNST_PRGBR"
    fi
elif [ "$CHK_VISMOD" = 'eyecandy' ]; then
    PANEL_C1="$EYEC_TINT2_GRAD1"
    PANEL_C2="$EYEC_TINT2_GRAD2"
    PANEL_SB="$EYEC_START_BUTTON"
    if [ -n "$CHK_MINMOD" ]; then
        NOTIFYD_FG="$EYEC_MIN_DUNST_SMMRY"
        NOTIFYD_PB="$EYEC_MIN_DUNST_PRGBR"
    else
        NOTIFYD_FG="$EYEC_DUNST_SMMRY"
        NOTIFYD_PB="$EYEC_DUNST_PRGBR"
    fi
fi

notifyd()
{
    # Set dunst notification daemon summary color, opacity level, and web browser from "~/.joyful_desktop".
    sed -e "/format/s|foreground='.*'|foreground='${NOTIFYD_FG}'|" \
        -e "/highlight/s|= \".*\"|= \"${NOTIFYD_PB}\"|"            \
        -i "${DUNST_DIR}/${CHK_DUNST}.dunstrc"
    sed -e "/transparency/s|=.*|= $((100-${DUNST:-100}))|" \
        -e "/browser/s|=.*|= \"${WEB_BROWSER}\"|"          \
        -si "$DUNST_DIR"/*.'dunstrc'
    # Run dunst notification daemon.
    dunst -config "${DUNST_DIR}/${CHK_DUNST}.dunstrc" &
}
    
paneld()
{
    {
        # Set tint2 panel main button colors and glyphs from "~/.joyful_desktop".
        sed -e "/start_color/s|= START_COLOR|= ${PANEL_C1}|" \
            -e "/end_color/s|= END_COLOR|= ${PANEL_C2}|"     \
            -e "/button_text/s|= ⟐|= ${PANEL_SB}|"          \
            -si "${TINT2_DIR}/${CHK_VISMOD}"-*.'tint2rc'
        # Run tint2 panel.
        tint2 -c "${TINT2_DIR}/${CHK_VISMOD}-${CHK_PANEL_ORT}.tint2rc"
        # Rollback tint2 panel main button color and glyphs from "~/.joyful_desktop".
        sed -e "/start_color/s|= ${PANEL_C1}|= START_COLOR|" \
            -e "/end_color/s|= ${PANEL_C2}|= END_COLOR|"     \
            -e "/button_text/s|= ${PANEL_SB}|= ⟐|"          \
            -si "${TINT2_DIR}/${CHK_VISMOD}"-*.'tint2rc'
        
    } &
}

{
    # Set terminal opacity level from "~/.joyful_desktop".
    "${VISMOD_DIR}/terminal-set.sh" transparency
    
    # Set partial accent colors from "~/.joyful_desktop".
    "${VISMOD_DIR}/${CHK_VISMOD}/theme${DOTMINMOD}.sh" partially
    
    unset LC_ALL; export LANG="$OLD_LANG"
    
    # Run dunst notification daemon.
    notifyd
    
    case ${1} in
        minimal)   # Set X wallpaper.
                   nitrogen --set-zoom-fill --save "${WALLPAPER_DIR}/${CHK_WALLPAPER}"
                   # Run tint2 panel.
                   tint2 -c "${TINT2_DIR}/statint-${CHK_VISMOD}.tint2rc" &
        ;;
        partially) # Run tint2 panel.
                   paneld
        ;;
        *)         # Set X wallpaper.
                   nitrogen --set-zoom-fill --save "${WALLPAPER_DIR}/${CHK_WALLPAPER}"
                   # Run tint2 panel.
                   paneld
        ;;
    esac
    
} >/dev/null 2>&1

exit ${?}
