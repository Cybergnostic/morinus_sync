#!/usr/bin/env bash
set -euo pipefail

UNIT_DIR="${HOME}/.config/systemd/user"
mkdir -p "$UNIT_DIR"

SRC="${HOME}/MorinusChartsRepo/systemd/hors-sync.service"
DST="${UNIT_DIR}/hors-sync.service"

cp -f "$SRC" "$DST"
systemctl --user daemon-reload
systemctl --user enable --now hors-sync

echo "[✓] hors-sync service enabled and started (user-level)."