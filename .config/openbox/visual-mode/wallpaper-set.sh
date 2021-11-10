#!/usr/bin/env sh

# ~/.config/openbox/visual-mode/wallpaper-set.sh: Setup X wallpapers, etc.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

case ${1} in
    generate) (
                  # Ensure imagemagick `identify` and `magick` already installed.
                  command -v identify && command -v magick || exec notify-send.sh -u low -r 81 'Install `imagemagick`!'
                  # Generate wallapaper (colorized) from "~/.wallpapers/*.*".
                  cd "$WALLPAPER_RAW_DIR"
                  for RAW in *.*; do
                      # Ensure $RAW is valid image.
                      if [ -f "$RAW" ] && GET_WP_SIZE="$(identify -format '%w' "$RAW")" && [ -n "$GET_WP_SIZE" ] ; then
                          # Send generate notification per wallpapers.
                          notify-send.sh -r 81 -t 750 -i "$WALLPAPER_ICON" '' "Generating ..\n<span size='small'><u>${RAW}</u></span>"
                          # Adds wallpaper size resolution naming.
                          if [ "$GET_WP_SIZE" -lt 1280 ]; then
                              SIZE=''
                          elif [ "$GET_WP_SIZE" -lt 1920 ]; then
                              SIZE='_HD'
                          elif [ "$GET_WP_SIZE" -lt 2048 ]; then
                              SIZE='_FHD'
                          elif [ "$GET_WP_SIZE" -lt 2880 ]; then
                              SIZE='_2K'
                          elif [ "$GET_WP_SIZE" -lt 3840 ]; then
                              SIZE='_3K'
                          elif [ "$GET_WP_SIZE" -lt 5120 ]; then
                              SIZE='_4K'
                          elif [ "$GET_WP_SIZE" -lt 6144 ]; then
                              SIZE='_5K'
                          elif [ "$GET_WP_SIZE" -lt 7168 ]; then
                              SIZE='_6K'
                          elif [ "$GET_WP_SIZE" -lt 7680 ]; then
                              SIZE='_7K'
                          elif [ "$GET_WP_SIZE" -eq 7680 ]; then
                              SIZE='_8K'
                          else
                              SIZE='_ULTRA'
                          fi
                          # Now convert.
                          if [ "$CHK_VISMOD" = 'mechanical' ]; then
                              magick "$RAW" -gravity center -crop 16:9 \( -clone 0 -fill '#4c566a' -colorize 50% \) -gravity center -compose lighten -composite \( -clone 0 -fill '#4c566a' -colorize 20% \) -gravity center -compose darken -composite -quality 100% "${WALLPAPER_DIR}/${RAW%%.*}${SIZE}.jpg" || exit ${?}
                          elif [ "$CHK_VISMOD" = 'eyecandy' ]; then
                              magick "$RAW" -gravity center -crop 16:9 \( -clone 0 -fill white -colorize 20% -modulate 100,127,97 \) -fill black -colorize 2.2% -gravity center -compose lighten -composite -quality 100% "${WALLPAPER_DIR}/${RAW%%.*}${SIZE}.jpg" || exit ${?}
                          fi
                          # Send successful notification.
                          exec notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' "Successfuly generated!\n<span size='small'>Now change the wallpaper!</span>"
                      elif [ -d "$RAW" ]; then
                          shift
                      else
                          exec notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' 'Nothing will be generated!'
                      fi
                  done
                  
              ) >/dev/null 2>&1
    ;;
    *)        # ANSI color codes.
              RB='\033[0m\033[5;31m' BB='\033[0m\033[5;34m' W='\033[1;37m' NC='\033[0m' m='\033[0;35m' g='\033[0;32m'
              # Parse modes in order to uppercase words.
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
                  sed -i "/wallpaper${DOTMINMOD} /s|\".*\"|\"${WALLPAPER##*/}\"|" "$THEME_FILE"
                  # Send successful notification.
                  notify-send.sh -u low -r 81 -i "$WALLPAPER_ICON" '' "<span size='small'><u>${WALLPAPER##*/}</u></span>\n Sucessfully applied!"
              fi
    ;;
esac

exit ${?}
