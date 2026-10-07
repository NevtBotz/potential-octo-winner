#!/usr/bin/env bash
set -euo pipefail

INSTALLER="$HOME/workspaces/$(basename "${GITHUB_REPOSITORY:-cloud-desktop}")/scripts/setup-cloudflare-desktop-v3.bin"
MARKER="$HOME/.cloud-desktop-installed"

# Find installer robustly if the repository path differs.
if [[ ! -f "$INSTALLER" ]]; then
  INSTALLER="$(find "$HOME/workspaces" -maxdepth 4 -type f -name 'setup-cloudflare-desktop-v3.bin' 2>/dev/null | head -n1 || true)"
fi

if [[ -f "$INSTALLER" ]]; then
  chmod +x "$INSTALLER"
fi

if [[ ! -f "$MARKER" ]]; then
  echo
  echo "============================================================"
  echo " Cloud Linux Desktop — first-time setup"
  echo "============================================================"
  echo
  echo "Run once:"
  echo "  $INSTALLER"
  echo
  echo "After setup, the Codespace will auto-start the desktop"
  echo "when CF_TUNNEL_TOKEN is configured as a Codespaces Secret."
  echo
  mkdir -p "$(dirname "$MARKER")"
  touch "$MARKER"
fi
