#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/wallpaper-set.sh: Setup X wallpapers, etc.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

get_size()
{
    SIZE="$(identify -format '%w' "$RAW")"
    if [ "$SIZE" -lt 1280 ]; then
        echo ''
    elif [ "$SIZE" -lt 1920 ]; then
        echo '_HD'
    elif [ "$SIZE" -lt 2048 ]; then
        echo '_FHD'
    elif [ "$SIZE" -lt 2880 ]; then
        echo '_2K'
    elif [ "$SIZE" -lt 3840 ]; then
        echo '_3K'
    elif [ "$SIZE" -lt 5120 ]; then
        echo '_4K'
    elif [ "$SIZE" -lt 6144 ]; then
        echo '_5K'
    elif [ "$SIZE" -lt 7168 ]; then
        echo '_6K'
    elif [ "$SIZE" -lt 7680 ]; then
        echo '_7K'
    elif [ "$SIZE" -eq 7680 ]; then
        echo '_8K'
    else
        echo '_ULTRA'
    fi
}

case ${1} in
    generate) # Ensure `imagemagick` already installed.
              { command -v identify && command -v convert; } >/dev/null 2>&1 || exec notify-send.sh -u low -r 81 'Install `imagemagick`!'
              # Generate wallapaper (colorized) from "~/.wallpapers/*.*".
              (
                  cd "$WALLPAPER_RAW_DIR"
                  for RAW in *.*; do
                      # Ensure there's a file.
                      [ -f "$RAW" ] || exec notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' 'Nothing will be generated!'
                      # Send generate notification per wallpapers.
                      notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' "Generating ..\n<span size='small'><u>${RAW}</u></span>"
                      # Now convert.
                      if [ "$CHK_VISMOD" = 'mechanical' ]; then
                          convert "$RAW" -gravity center -crop 16:9 \( +clone -fill '#4c566a' -colorize 50% \) -gravity center   \
                          -compose lighten -composite \( +clone -fill '#4c566a' -colorize 20% \) -gravity center -compose darken \
                          -composite -quality 100% "${WALLPAPER_DIR}/${RAW%%.*}$(get_size).jpg" || exit ${?}
                      elif [ "$CHK_VISMOD" = 'eyecandy' ]; then
                          convert "$RAW" -gravity center -crop 16:9 \( +clone -fill white -colorize 20% -modulate 100,127,97 \)  \
                          -fill black -colorize 2.2% -gravity center -compose lighten -composite -quality 100%                   \
                          "${WALLPAPER_DIR}/${RAW%%.*}$(get_size).jpg" || exit ${?}
                      fi
                      # Send successful notification.
                      exec notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' 'Successfuly generated!'
                  done
                  
              ) >/dev/null 2>&1
    ;;
    *)        # ANSI color codes.
              RB='\033[0m\033[5;31m' BB='\033[0m\033[5;34m' W='\033[1;37m' NC='\033[0m' m='\033[0;35m' g='\033[0;32m'
              # Parse modes in order to capitalize words.
              GUESS_MODE="$([ -z "$CHK_MINMOD" ] || echo 'MINIMAL ')$(echo "$CHK_VISMOD" | tr '[:lower:]' '[:upper:]')"
              # Select wallpaper per modes.
              printf "${W}AVAILABLE WALLPAPERS FOR ${GUESS_MODE} THEME:${NC}\n"
              for WALLPAPER in "$WALLPAPER_DIR"/*.*; do
                  N=$((N+1)); printf "${m}[${NC}${N}${m}]$([ "${WALLPAPER##*/}" = "$CHK_WALLPAPER" ] && echo "$g" || \
                  echo "$NC" ) ${WALLPAPER##*/}${NC}\n"
                  eval "WALLPAPER${N}=\$WALLPAPER"
              done
              printf "${W}ENTER INDEX-NUMBER\n${RB}>${m}>${BB}>${NC} "
              read -r NUM; NUM="$(echo "$NUM" | tr -dc '[:digit:]')"
              if [ "${NUM:-0}" -eq 0 ] || [ "${NUM:-0}" -gt "$N" ]; then
                  printf "${RB}WRONG SELECTION!${NC}\n" >&2
                  exit 1
              else
                  eval "WALLPAPER=\$WALLPAPER${NUM}"
                  # Set current wallpaper.
                  nitrogen --set-zoom-fill --save "$WALLPAPER" >/dev/null 2>&1
                  # Write current wallpaper to configuration.
                  sed -i "/wallpaper$([ -z "$CHK_MINMOD" ] || echo '.minimal') /s|\".*\"|\"${WALLPAPER##*/}\"|" "$THEME_FILE"
                  # Send successful notification.
                  notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' "<span size='small'><u>${WALLPAPER##*/}</u></span>\n Sucessfully applied!"
              fi
    ;;
esac

exit ${?}
