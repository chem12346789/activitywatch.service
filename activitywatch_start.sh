#!/bin/bash

set -u

LOG_SERVER=/tmp/aw-server.log
LOG_AWATCHER=/tmp/aw-awatcher.log
LOG_SYNC=/tmp/aw-sync.log

import_session_env() {
    local pid
    pid="$(pgrep -u "$(id -u)" -o -f 'gnome-shell|gnome-session-binary' | head -1 || true)"
    [ -z "$pid" ] && return 1

    while IFS='=' read -r key val; do
        case "$key" in
            DISPLAY|XAUTHORITY|XDG_RUNTIME_DIR|WAYLAND_DISPLAY|DBUS_SESSION_BUS_ADDRESS)
                export "$key=$val"
                ;;
        esac
    done < <(tr '\0' '\n' < "/proc/$pid/environ")

    return 0
}

# Wait for graphical session env after reboot/login
for _ in $(seq 1 30); do
    import_session_env || true
    [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "${XDG_RUNTIME_DIR:-}" ] || export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
    if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        break
    fi
    sleep 2
done

export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

cd $HOME/.local/opt/activitywatch

# Start aw-server-rust once
if ! pgrep -u "$(id -u)" -f '/aw-server-rust/aw-server-rust' >/dev/null 2>&1; then
    ./aw-server-rust/aw-server-rust >>"$LOG_SERVER" 2>&1 &
    sleep 2
fi

# Start aw-sync daemon once
if ! pgrep -u "$(id -u)" -f '/aw-server-rust/aw-sync daemon' >/dev/null 2>&1; then
    ./aw-server-rust/aw-sync daemon >>"$LOG_SYNC" 2>&1 &
fi

# Keep this service tied to aw-awatcher lifecycle
exec /usr/bin/aw-awatcher >>"$LOG_AWATCHER" 2>&1
