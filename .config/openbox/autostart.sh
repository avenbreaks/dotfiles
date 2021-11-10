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
    pgrep "$EXEC_TRAY" >/dev/null 2>&1  || \
    [ -x "$(command -v "$EXEC_TRAY")" ] && \
    eval "\"$EXEC_TRAY\" >/dev/null 2>&1 &"
done

# Run compositor.
picom -b >/dev/null 2>&1

# Run authentication agent (PolicyKit).
if [ -x "$(command -v lxpolkit)" ]; then
    lxpolkit >/dev/null 2>&1 &
elif POLKIT_GNOME="$(find /usr/local/lib /usr/local/libexec /usr/local/lib64 /usr/local/libexec64 /usr/lib /usr/libexec /usr/lib64 /usr/libexec64 ${HOME}/.nix-profile/lib ${HOME}/.nix-profile/libexec ${HOME}/.nix-profile/lib64 ${HOME}/.nix-profile/libexec64 -type f -iname 'polkit-gnome-authentication-agent-1' 2>/dev/null | sed 1q)" && [ -x "$POLKIT_GNOME" ]; then
    "$POLKIT_GNOME" >/dev/null 2>&1 &
fi

# Run session auto-locker.
xautolock -time "$AUTOLOCK_MINUTE" -locker "$("$LAUNCH_APPS" -g lockscreen)" -detectsleep -resetsaver -corners 00-- -cornersize 1000 \
-notifier "notify-send.sh -i ${LOCK_ICON} 'Lockscreen' 'Will be locked in 5s from now!'" -notify 5 >/dev/null 2>&1 &

# Run MPD with notification-sender whenever track was changed.
"$MPD_PLUS_NOTIFIER"
