#!/bin/sh
set -eu

# jlesage's web server reads WEB_LISTENING_PORT, not PORT. Railway injects PORT
# and its HTTP healthcheck dials that injected port, so map one onto the other.
export WEB_LISTENING_PORT="${PORT:-5800}"

# Real web authentication is on by default (baked in the image). Refuse to boot
# with an empty password rather than serve an open remote-browser desktop.
if [ "${WEB_AUTHENTICATION:-1}" = "1" ] && [ -z "${WEB_AUTHENTICATION_PASSWORD:-}" ]; then
    echo "[railway] FATAL: WEB_AUTHENTICATION_PASSWORD is empty. The template defaults it to a generated secret; set one." >&2
    exit 1
fi

# The raw VNC channel gets its own per-deploy password too (defence in depth).
if [ -z "${VNC_PASSWORD:-}" ]; then
    echo "[railway] FATAL: VNC_PASSWORD is empty. The template defaults it to a generated secret; set one." >&2
    exit 1
fi

echo "[railway] Chromium web desktop on :$WEB_LISTENING_PORT (web-auth user '${WEB_AUTHENTICATION_USERNAME:-admin}'), CDP on :${CHROMIUM_REMOTE_DEBUGGING_PORT:-9222} (private network only), profile at /config on the volume" >&2
exec "$@"
