#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.cloud-desktop/config.env"
RUNTIME="$HOME/.cloud-desktop/start-desktop.sh"
PIDFILE="$HOME/.cloud-desktop/runtime.pid"
LOGFILE="$HOME/.cloud-desktop/runtime.log"

if [[ ! -f "$CONFIG" || ! -x "$RUNTIME" ]]; then
  echo "[cloud-desktop] Not installed yet."
  echo "[cloud-desktop] Run the installer from scripts/setup-cloudflare-desktop-v3.bin"
  exit 0
fi

# Codespaces injects repository/user secrets as environment variables.
if [[ -z "${CF_TUNNEL_TOKEN:-}" ]]; then
  echo "[cloud-desktop] CF_TUNNEL_TOKEN is not available."
  echo
  echo "Add a GitHub Codespaces Secret named:"
  echo "  CF_TUNNEL_TOKEN"
  echo
  echo "Then rebuild/restart the Codespace."
  exit 0
fi

# Prevent duplicate runtime processes.
if [[ -f "$PIDFILE" ]]; then
  PID="$(cat "$PIDFILE" 2>/dev/null || true)"
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    echo "[cloud-desktop] Runtime already running (PID $PID)."
    exit 0
  fi
  rm -f "$PIDFILE"
fi

mkdir -p "$(dirname "$LOGFILE")"

nohup "$RUNTIME" >>"$LOGFILE" 2>&1 &
PID=$!
echo "$PID" > "$PIDFILE"

sleep 2

if kill -0 "$PID" 2>/dev/null; then
  echo "[cloud-desktop] Desktop runtime started (PID $PID)."
  echo "[cloud-desktop] Log: $LOGFILE"
else
  echo "[cloud-desktop] Runtime exited early. Check:"
  echo "  tail -100 $LOGFILE"
  rm -f "$PIDFILE"
  exit 1
fi
