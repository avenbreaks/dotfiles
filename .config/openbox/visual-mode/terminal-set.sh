#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/terminal-set.sh: Setup terminal transparency, colors, etc.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `urxvt` already installed.
command -v urxvt >/dev/null 2>&1 || exec notify-send.sh -u low -r 79 'Install `rxvt-unicode`!'

# Set URxvt icon file automatically and URL launcher from "~/.joyful_desktop".
sed -e "/URxvt.iconFile/s|:.*|:                   ${TERMINAL_ICON}|" \
    -e "/URxvt.url-select.launcher/s|:.*|:        ${WEB_BROWSER}|"   \
    -i "$XRESOURCES_CONFIG"
    
transparency()
{
    # Set `urxvt` depth to 32 a.k.a alpha-enabled if opacity lower than 100 from "~/.joyful_desktop".
    if [ "${URXVT:-100}" -lt 100 ]; then
        sed -i '/URxvt.depth/s|:.*|:                      32|' "$XRESOURCES_CONFIG"
    else
        sed -i '/URxvt.depth/s|:.*|:                      24|' "$XRESOURCES_CONFIG"
    fi
    
    case ${1} in
        apply) # Apply `urxvt` current transparency from "~/.joyful_desktop".
               if [ -n "$FG_WHITE" ]; then
                   sed -e "/#define black0/s|\[.*\]|\[${URXVT:-100}\]|" \
                       -e "/#define white0/s|\[.*\]|\[100\]|"           \
                       -i "$XRESOURCES_CONFIG"
               elif [ -n "$FG_BLACK" ]; then
                   sed -e "/#define white0/s|\[.*\]|\[${URXVT:-100}\]|" \
                       -e "/#define black0/s|\[.*\]|\[100\]|"           \
                       -i "$XRESOURCES_CONFIG"
               fi
        ;;
        swap)  # Apply `urxvt` reversed transparency from "~/.joyful_desktop".
               if [ -n "$FG_BLACK" ]; then
                   sed -e "/#define black0/s|\[.*\]|\[${URXVT:-100}\]|" \
                       -e "/#define white0/s|\[.*\]|\[100\]|"           \
                       -i "$XRESOURCES_CONFIG"
               elif [ -n "$FG_WHITE" ]; then
                   sed -e "/#define white0/s|\[.*\]|\[${URXVT:-100}\]|" \
                       -e "/#define black0/s|\[.*\]|\[100\]|"           \
                       -i "$XRESOURCES_CONFIG"
               fi
        ;;
    esac
}

CURRENT_TERM="$("$LAUNCH_APPS" -g terminal)"

if [ "$CURRENT_TERM" = 'urxvt' ]; then
    FG_BLACK="$(grep 'foreground.*black0' "$XRESOURCES_CONFIG" | grep -Fv '!')"
    FG_WHITE="$(grep 'foreground.*white0' "$XRESOURCES_CONFIG" | grep -Fv '!')"
    case ${1} in
        transparency) # Sync transparency.
                      transparency apply
        ;;
        *)            # Reverse between background-foreground.
                      transparency swap
                      sed -e '/^\*.foreground/s|*|!*TEMP|'  \
                          -e '/^\*.background/s|*|!*TEMP|'  \
                          -e '/^\*.cursorColor/s|*|!*TEMP|' \
                          -e '/^\*.color0/s|*|!*TEMP|'      \
                          -e '/^*.color7/s|*|!*TEMP|'       \
                          -e '/^\*.color8/s|*|!*TEMP|'      \
                          -e '/^\*.color15/s|*|!*TEMP|'     \
                          -e '/^!\*.foreground/s|!||'       \
                          -e '/^!\*.background/s|!||'       \
                          -e '/^!\*.cursorColor/s|!||'      \
                          -e '/^!\*.color0/s|!||'           \
                          -e '/^!\*.color7/s|!||'           \
                          -e '/^!\*.color8/s|!||'           \
                          -e '/^!\*.color15/s|!||'          \
                          -e '/^!\*TEMP/s|TEMP||'           \
                          -i "$XRESOURCES_CONFIG"
        ;;
    esac
    # Load X resource database.
    xrdb "$XRESOURCES_CONFIG" >/dev/null 2>&1 &
fi

exit ${?}
