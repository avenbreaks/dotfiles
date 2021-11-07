#!/usr/bin/env sh

# ~/.config/rofi/scripts/apps.sh: Run rofi apps-menu.
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=

exec rofi -no-lazy-grab -show drun -theme themes/appsmenu.rasi

exit ${?}
