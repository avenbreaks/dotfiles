#!/usr/bin/env sh
#
# These things are run when an Openbox X Session is started.
# You may place a similar script in "${HOME}/.config/openbox/autostart" to run user-specific things.
#
# aHR0cHM6Ly9naXRodWIuY29tL293bDRjZS9kb3RmaWxlcwo=
# ---

# Load Joyful Desktop environment variables.
. "${HOME}/.joyful_desktop"

# Run audio-server, there was once a pulseaudio here.
#pulseaudio >/dev/null 2>&1 &

# Start user interface and tray.
"${VISMOD_DIR}/toggle-mode.sh" just_ui
for EXEC_TRAY in $(echo "$CHK_TRAY"); do
    pgrep "$EXEC_TRAY" >/dev/null 2>&1 || \
    eval "\"$EXEC_TRAY\" >/dev/null 2>&1 &"
done

# Run compositor.
picom -b >/dev/null 2>&1

# Run authentication agent (PolicyKit).
if [ -x "$(command -v lxpolkit)" ]; then
    eval "lxpolkit >/dev/null 2>&1 &"
elif [ -x '/usr/libexec/polkit-gnome-authentication-agent-1' ]; then
    eval "/usr/libexec/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &"
fi

# Run session auto-locker.
xautolock -time "$AUTOLOCK_MINUTE" -locker "$("$LAUNCH_APPS" -g lockscreen)" -detectsleep -resetsaver -corners 00-- -cornersize 1000 \
-notifier "${V_NOTIFIER} -i ${LOCK_ICON} 'Lockscreen' 'Will be locked in 5s from now!'" -notify 5 >/dev/null 2>&1 &

# Run MPD with notification-sender whenever track was changed.
"$MPD_PLUS_NOTIFIER"
