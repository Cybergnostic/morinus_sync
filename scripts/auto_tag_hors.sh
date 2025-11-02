#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${HOME}/MorinusChartsRepo"
WATCH_DIR="${REPO_DIR}/Hors"
USER_TAG="$(whoami)"

# Avoid parallel instances
LOCKFILE="/tmp/hors-sync.lock"
exec 9>"$LOCKFILE"
flock -n 9 || { echo "Another hors-sync is running. Exiting."; exit 0; }

cd "$REPO_DIR"

# One safe sync before we start
git pull --rebase --autostash || true

echo "[*] Watching: $WATCH_DIR"
inotifywait -m -e close_write,create,move --format "%f" "$WATCH_DIR" | \
while read -r FNAME; do
  # Only .hor files
  [[ "$FNAME" == *.hor ]] || continue

  # If not tagged for this user, rename to add suffix "_<user>.hor"
  if [[ "$FNAME" != *_${USER_TAG}.hor ]]; then
    OLD_PATH="${WATCH_DIR}/${FNAME}"
    BASE="${FNAME%.hor}"
    NEW_NAME="${BASE}_${USER_TAG}.hor"
    NEW_PATH="${WATCH_DIR}/${NEW_NAME}"

    # If target exists (rare), add timestamp
    if [[ -e "$NEW_PATH" ]]; then
      NEW_NAME="${BASE}_${USER_TAG}_$(date +%Y%m%d%H%M%S).hor"
      NEW_PATH="${WATCH_DIR}/${NEW_NAME}"
    fi

    mv "$OLD_PATH" "$NEW_PATH"
    echo "[+] Renamed ${FNAME} -> ${NEW_NAME}"
  fi

  # Sync cycle: pull, add, commit, push
  git pull --rebase --autostash || true
  git add Hors/*.hor || true
  git commit -m "Auto tag + sync (${USER_TAG}) $(date -Iseconds)" || true
  git push || true
done