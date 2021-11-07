#!/usr/bin/env sh

# ~/.scripts/screenshot-draw.sh: Take a screenshot with selection or draw rectangle.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `scrot` already installed.
command -v scrot >/dev/null 2>&1 || exec notify-send.sh -u low -r 74 'Install `scrot`!'

{
    sleep .21s
    rm -f /tmp/*_scrot*.png
    
    if scrot -q "${QUALITY:-75}" -sfbe 'mv -f $f /tmp/' -l style=dash,width=3,color='#2be491'; then
        notify-send.sh -r 74 -t 750 -i "$SCREENSHOT_ICON" '' 'Processing captured image ..'
    else
        exec notify-send.sh -r 74 -t 500 -i "$SCREENSHOT_ICON" '' 'Screenshot canceled!'
    fi
    
    for CURRENT in /tmp/*_scrot*.png; do
        CURRENT="${CURRENT##/tmp/}" CURRENT="${CURRENT%%.png}"
    done
    
    if [ "$ENABLE_FRAME" = 'yes' ]; then
        if [ "$FRAME_COLOR" = 'auto' ]; then
            FRAME_COLOR="$(convert "/tmp/${CURRENT}.png" -scale 50x50! -depth 8 +dither -colors 8 -format '%c' histogram:info: | sort -nr | grep -oE '[#][0-9a-fA-F]*' | sed 1q)"
        fi
        if echo "$FRAME_COLOR" | grep -qoE '^[#][0-9a-fA-F]{1,}$'; then
            FRAME_COLOR="${FRAME_COLOR:-#434c5e}"
        else
            notify-send.sh -u low -r 74 -i "$SCREENSHOT_ICON" '' "Screenshot failed!\n<span size='small'><u>${FRAME_COLOR}</u> isn't hexadecimal!</span>"
            exec rm -f "/tmp/${CURRENT}.png"
        fi
        eval "sleep .75s && notify-send.sh -r 74 -t 750 -i \"$SCREENSHOT_ICON\" '' \"Applying ${FRAME_COLOR} ..\" &"
        convert "/tmp/${CURRENT}.png" \( +clone -alpha extract -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
        \( +clone -flip \) -compose Multiply -composite \( +clone -flop \) -compose Multiply -composite \) -alpha off -compose  \
        CopyOpacity -composite "/tmp/${CURRENT}-rounded.png" && rm -f "/tmp/${CURRENT}.png" || exit ${?}
        convert "/tmp/${CURRENT}-rounded.png" \( +clone -background black -shadow                                               \
        "${FRAMED_SHADOW_OPACITY:-25}x${FRAME_PADDING:-10}+0+$(echo "${FRAME_PADDING:-10}/2" | bc)" \) +swap -background none   \
        -layers merge +repage "/tmp/${CURRENT}-shadow.png" && rm -f "/tmp/${CURRENT}-rounded.png" || exit ${?}
        convert "/tmp/${CURRENT}-shadow.png" -bordercolor "$FRAME_COLOR"                                                        \
        -border 5 "/tmp/${CURRENT}.png" && rm -f "/tmp/${CURRENT}-shadow.png" || exit ${?}
    fi
    
    while :; do
        if [ "$COPY2CLIP" = 'yes' ] && [ -x "$(command -v xclip)" ]; then
            xclip -selection clipboard -target image/png -i "/tmp/${CURRENT}.png"
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
        mv -f "/tmp/${CURRENT}.png" "${SAVE_DIR}/Screenshots/"
        STS1="${SAVE_DIR##*/}/Screenshots"
    else
        rm -f "/tmp/${CURRENT}.png"
        STS2='CLIPBOARD'
    fi
    
    if [ -f "${SAVE_DIR}/Screenshots/${CURRENT}.png" ] && [ "$OPEN_FRAMED" = 'yes' ] && [ -x "$(command -v viewnior)" ]; then
        eval "viewnior \"${SAVE_DIR}/Screenshots/${CURRENT}.png\" &"
    fi 
    
    exec notify-send.sh -u low -r 74 -i "$SCREENSHOT_ICON" '' "<span size='small'><u>${STS1}</u><i>${STS2}</i></span>\nPicture acquired!"
    
} >/dev/null 2>&1 &

exit ${?}
