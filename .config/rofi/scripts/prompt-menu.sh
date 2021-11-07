#!/usr/bin/env sh

# ~/.config/rofi/scripts/prompt-menu.sh: Run rofi prompt-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution.
export LC_ALL=POSIX LANG=POSIX

ROFI='rofi -theme themes/promptmenu.rasi'

yes_text='' no_text='' query='Are you sure?'

while [ "$#" -ne 0 ]; do
    case ${1} in
        -o|--yes-text)    if [ -n "${2}" ]; then
                              yes_text="${2}"
                          else
                              yes_text=''
                          fi
                          shift
        ;;
        -c|--no-text)     if [ -n "${2}" ]; then
                              no_text="${2}"
                          else
                              no_text=''
                          fi
                          shift
        ;;
        -y|--yes-command) if [ -n "${2}" ]; then
                              yes_command="${2}"
                          fi
                          shift
        ;;
        -n|--no-command)  if [ -n "${2}" ]; then
                              no_command="${2}"
                          fi
                          shift
        ;;
        -q|--query)       if [ -n "${2}" ]; then
                              query="${2}"
                          fi
                          shift
        ;;
    esac
    shift
done

MENU="$(printf "${yes_text}\n${no_text}\n" | ${ROFI} -p "$query" -dmenu -selected-row 1)"

case "$MENU" in
    "$yes_text") eval "$yes_command"
    ;;
    "$no_text")  eval "$no_command"
    ;;
esac

exit ${?}
