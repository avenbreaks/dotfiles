#!/usr/bin/env sh

# ~/.config/ncmpcpp/scripts/single.album-art.sh: Show album-art (without playlists) in ncmpcpp.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Ensure `mpd` and `mpc` already installed.
{ command -v mpd && command -v mpc; } >/dev/null 2>&1 || exit 1

# Alias `mpc` to port 7777.
alias mpc="mpc -p ${MPD_PORT}"

w3m()
{
    [ "$1" != 'clear' ] || exit ${?}
    
    # ANSI color codes.
    R='\033[1;31m' NC='\033[0m' CL='\033c' m='\033[0;35m'
    
    # Find `w3mimgdisplay` executables.
    W3M="$(find /usr/local/lib /usr/local/libexec /usr/local/lib64 /usr/local/libexec64 /usr/lib /usr/libexec /usr/lib64 /usr/libexec64 ${HOME}/.nix-profile/lib ${HOME}/.nix-profile/libexec ${HOME}/.nix-profile/lib64 ${HOME}/.nix-profile/libexec64 -type f -path '*/w3m/*' -iname 'w3mi*' 2>/dev/null | sed 1q)"
    
    sleep .25s
    
    if [ -x "$(command -v xprop)" ] && [ -x "$(command -v xwininfo)" ]; then
        WIN_ID="$(xprop -root _NET_ACTIVE_WINDOW | grep -oE '[^# ]+$')"
        while :; do
            GET_W="$(xwininfo -id "$WIN_ID" 2>/dev/null | grep -oE 'Width:[ ]*[0-9]*' | cut -d' ' -f2)"
            #GET_H="$(xwininfo -id "$WIN_ID" 2>/dev/null | grep -oE 'Height:[ ]*[0-9]*' | cut -d' ' -f2)"
            if [ -n "$GET_W" -o -n "$GET_H" ]; then
                W_RES="$(echo "${GET_W}/1.166" | bc)"
                #H_RES="$(echo "${GET_H}/1.29" | bc)"
            fi
            sleep .25s
            if [ -n "$W_RES" -o -n "$H_RES" ]; then
                # Keep image aspect ratio by depend on width for both.
                printf '%b\n%s;\n%s\n' "0;1;0;0;${W_RES};${W_RES};;;;;${COVER_JPG}" 3 4 | "${W3M:-false}" >/dev/null 2>&1
            else
                printf "${CL}${R}error:${NC} window ${m}width${NC} or ${m}height${NC} invalid!" >&2 
            fi
        done
    else
        printf "${CL}${R}error:${m} xorg-xprop${NC} and/or ${m}xorg-xwininfo${NC} aren't installed!" >&2 
    fi
}

pixbuf()
{
    if [ "$1" = 'clear' ]; then
        printf '\033]20;;100x100+1000+1000\a'
    else
        printf "\033]20;${COVER_JPG};67x67+00+00:op=keep-aspect\a"
    fi
}

{
    COVER_JPG="$NCMPCPP_COVER"
    
    ALBUM="$(mpc --format '%album%' current)"
    FILE="$(mpc --format '%file%' current)"
    
    ALBUM_DIR="${FILE%/*}"
    
    [ -n "$ALBUM_DIR" ] || exit ${?}
    
    ALBUM_DIR="${MPD_MUSIC_DIR}/${ALBUM_DIR}"
    
    COVERS="$(find "$ALBUM_DIR" -type d -exec find "{}" -maxdepth 1 -type f -iregex ".*/.*\(${ALBUM}\|cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)" \;)"
    
    SOURCE="$(printf "$COVERS" | sed 1q)"
    
    if [ -n "$SOURCE" ]; then
        [ ! -f "$COVER_JPG" ] || rm -f "$COVER_JPG"
        # Scale image width to 500px and compress using ffmpeg or imagemagick, imagemagick as fallback.
        ffmpeg -i "$SOURCE" -vf scale=500:500 -crf 0 "$COVER_JPG" || magick "$SOURCE" -strip -interlace Plane -sampling-factor 4:2:0 -scale 500x -quality 85% "$COVER_JPG"
        if [ -f "$COVER_JPG" ]; then
            "$NCMPCPP_ALBUMART_BACKEND"
        fi
    else
        "$NCMPCPP_ALBUMART_BACKEND" clear
    fi
    
} >/dev/null 2>&1 &

exit ${?}
