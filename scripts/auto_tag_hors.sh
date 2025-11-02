#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${HOME}/projects/morinus_sync"
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
inotifywait -m -e close_write,create,moved_to --format "%f" "$WATCH_DIR" | \
while read -r FNAME; do
  # Only .hor/.HOR files
  shopt -s nocasematch
  [[ "$FNAME" =~ \.hor$ ]] || { shopt -u nocasematch; continue; }
  shopt -u nocasematch

  EXT="${FNAME##*.}"           # keeps original case of extension
  BASE="${FNAME%.*}"           # filename without extension
  # only rename if not already tagged for this user
  if [[ ! "$BASE" =~ _${USER_TAG}$ ]]; then
    NEW_NAME="${BASE}_${USER_TAG}.${EXT}"
    # avoid collisions
    [[ -e "${WATCH_DIR}/${NEW_NAME}" ]] && NEW_NAME="${BASE}_${USER_TAG}_$(date +%Y%m%d%H%M%S).${EXT}"
    mv "${WATCH_DIR}/${FNAME}" "${WATCH_DIR}/${NEW_NAME}"
    echo "[+] Renamed ${FNAME} -> ${NEW_NAME}"
  fi

  # Sync cycle: pull, add, commit, push
  git pull --rebase --autostash || true
  git add Hors/*.hor || true
  git commit -m "Auto tag + sync (${USER_TAG}) $(date -Iseconds)" || true
  git push || true
done