#!/usr/bin/env sh

# ~/.config/ncmpcpp/scripts/notify.album-art.sh: Show ncmpcpp album-art as notification.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `mpd`, `mpc`, and imagemagick `convert` already installed.
{ command -v mpd && command -v mpc && command -v convert; } >/dev/null 2>&1 || exit 1

# Alias `mpc` to port 7777.
alias mpc="mpc -p ${MPD_PORT}"

{
    COVER_JPG="$NCMPCPP_NOTIFY_COVER"
    COVER_PNG="${COVER_JPG%%.jpg}.png"
    
    ALBUM="$(mpc --format '%album%' current)"
    FILE="$(mpc --format '%file%' current)"
    
    ALBUM_DIR="${FILE%/*}"
    
    [ -n "$ALBUM_DIR" ] || exit ${?}
    
    ALBUM_DIR="${MPD_MUSIC_DIR}/${ALBUM_DIR}"
    
    COVERS="$(find "$ALBUM_DIR" -type d -exec find "{}" -maxdepth 1 -type f -iregex ".*/.*\(${ALBUM}\|cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)" \;)"
    
    SOURCE="$(printf "$COVERS" | sed 1q)"
    
    if [ -n "$SOURCE" ]; then
        [ ! -f "$COVER_PNG" ] || rm -f "$COVER_PNG"
        # Resize image width to 160px and round corners with imagemagick.
        convert "$SOURCE" -resize 160x \( +clone -alpha extract -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
        \( +clone -flip \) -compose Multiply -composite \( +clone -flop \) -compose Multiply -composite \) -alpha off -compose   \
        CopyOpacity -composite "$COVER_PNG"
        if [ -f "$COVER_PNG" ]; then
            notify-send.sh -r 78 -i "$COVER_PNG" '' "<span size='small'>$(mpc --format '%artist%' current)</span>\n$(mpc --format '%title%' current)"
        fi
    else
        notify-send.sh -r 78 -i "$MUSIC_ICON" '' "<span size='small'>$(mpc --format '%artist%' current)</span>\n$(mpc --format '%title%' current)"
    fi
    
} >/dev/null 2>&1 &

exit ${?}
