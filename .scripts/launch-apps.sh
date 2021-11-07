#!/usr/bin/env sh

# ~/.scripts/launch-apps.sh: Parse and launch user's preference applications.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

# Speeds up script execution, then restore UTF-8 before launching apps.
OLD_LANG="$LANG"; export LC_ALL=POSIX LANG=POSIX

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# ANSI color codes.
R='\033[1;31m' W='\033[1;37m' NC='\033[0m' g='\033[0;32m' m='\033[0;35m' r='\033[0;31m'

die() { >&2 printf "${R}%s${NC} %b\n" 'error:' "${@}"; exit 1; }

case ${1} in
    -g)    # Get applications from "~/.scripts/list-apps.joy".
           [ -n "${2}" ] || exit ${?}
           GET="$(grep "${2}[ ]*\".*\"" "$LIST_APPS_DB" | cut -d\" -f2)"
           if [ -n "$GET" ]; then
               echo "$GET"
           else
               die "${m}${2}${NC} isn't in the ${g}$(basename "$LIST_APPS_DB")${NC}. Define it first!"
           fi
    ;;
    ''|-*) # Print help messages.
           printf "${W}USAGE:${NC}\n"
           printf "${m}[${NC}X${m}] ${g}$(basename "${0}")${NC}    [${r}apps${NC}]\n"
           printf "${m}[${NC}?${m}] ${g}$(basename "${0}")${NC} -g [${r}apps${NC}]\n"
           printf "\n${W}AVAILABLE:${NC}\n"
           for APPS in $(cut -d\" -f1 "$LIST_APPS_DB"); do
               N=$((N+1)); printf "${m}[${NC}${N}${m}] ${r}${APPS} ${W}->${NC} $("${0}" -g "$APPS")\n"
           done | column -t
    ;;
    *)     # Launch applications from "~/.scripts/list-apps.joy".
           GET="$(grep "${1}[ ]*\".*\"" "$LIST_APPS_DB" | cut -d\" -f2)"
           if [ -n "$GET" ]; then
               unset LC_ALL; export LANG="$OLD_LANG"
               exec $(${GET} $([ -z "${2}" ] || echo ${@}) >/dev/null 2>&1 &)
           else
               die "${m}${1}${NC} isn't in the ${g}$(basename "$LIST_APPS_DB")${NC}. Define it first!"
           fi
    ;;
esac

exit ${?}
