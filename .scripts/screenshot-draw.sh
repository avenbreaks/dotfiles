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
            FRAME_COLOR="$(magick "/tmp/${CURRENT}.png" -strip -scale 50x50! -depth 8 +dither -colors 8 -format '%c' histogram:info: | sort -nr | grep -m1 -oE '[#][0-9a-fA-F]*')"
        fi
        if echo "$FRAME_COLOR" | grep -qoE '^[#][0-9a-fA-F]{1,}$'; then
            FRAME_COLOR="${FRAME_COLOR:-#434c5e}"
        else
            notify-send.sh -u low -r 74 -i "$SCREENSHOT_ICON" '' "Screenshot failed!\n<span size='small'><u>${FRAME_COLOR}</u> isn't hexadecimal!</span>"
            exec rm -f "/tmp/${CURRENT}.png"
        fi
        { sleep .75s && notify-send.sh -r 74 -t 750 -i "$SCREENSHOT_ICON" '' "Applying ${FRAME_COLOR} .."; } &
        # Convert (then delete the source) into rounded corners, then add shadows and border using imagemagick through miff-stream pipelines.
        magick ephemeral:"/tmp/${CURRENT}.png" \( -clone 0 -alpha extract -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \( -clone 0 -flip \) -compose Multiply -composite \( -clone 0 -flop \) -compose Multiply -composite \) -alpha off -compose CopyOpacity -composite -quality 100% miff:- | magick - \( -clone 0 -background black -shadow "${FRAMED_SHADOW_OPACITY:-25}x${FRAME_PADDING:-10}+0+$(echo "${FRAME_PADDING:-10}/2" | bc)" \) +swap -background none -layers merge +repage -quality 100% miff:- | magick - -bordercolor "$FRAME_COLOR" -border 5 -quality 100% "/tmp/${CURRENT}.png" || \
        { sleep .75s && exec notify-send.sh -u low -r 74 -i "$SCREENSHOT_ICON" '' "Screenshot failed!\n<span size='small'>Errors when processing image with \`imagemagick\`!</span>"; }
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
