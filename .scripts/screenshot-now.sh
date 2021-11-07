#!/usr/bin/env sh

# ~/.scripts/screenshot-now.sh: Take a screenshot directly.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `scrot` already installed.
command -v scrot >/dev/null 2>&1 || exec notify-send.sh -u low -r 75 'Install `scrot`!'

{
    [ "${@}" != 'delay' ] || sleep .21s
    
    while :; do
        if [ "$COPY2CLIP" = 'yes' ] && [ -x "$(command -v xclip)" ]; then
            CLIP='xclip -selection clipboard -target image/png -i $f ;'
            STS2='\nCLIPBOARD'
            break
        elif [ "$SAVE_SS" != 'yes' ]; then
            COPY2CLIP='yes'
        else
            break
        fi
    done
    
    if [ "$SAVE_SS" = 'yes' ]; then
        [ -d "${SAVE_DIR}/Screenshots" ] || install -d "${SAVE_DIR}/Screenshots"
        EXEC="${CLIP} mv -f \$f \"${SAVE_DIR}/Screenshots/\""
        STS1="${SAVE_DIR##*/}/Screenshots"
    else
        EXEC="${CLIP} rm -f \$f"
        STS2='CLIPBOARD'
    fi
    
    scrot -q "${QUALITY:-75}" -e "$EXEC" || exit ${?}
    
    exec notify-send.sh -u low -r 75 -i "$SCREENSHOT_ICON" '' "<span size='small'><u>${STS1}</u><i>${STS2}</i></span>\nPicture acquired!"
    
} >/dev/null 2>&1 &

exit ${?}
