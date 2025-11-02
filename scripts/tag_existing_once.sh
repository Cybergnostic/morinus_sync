#!/usr/bin/env bash
set -euo pipefail
DIR="$HOME/MorinusChartsRepo/Hors"
USER_TAG="$(whoami)"
shopt -s nullglob
for f in "$DIR"/*.hor; do
  base="$(basename "$f")"
  [[ "$base" == *_${USER_TAG}.hor ]] && continue
  new="${base%.hor}_${USER_TAG}.hor"
  [[ -e "$DIR/$new" ]] && new="${base%.hor}_${USER_TAG}_$(date +%Y%m%d%H%M%S).hor"
  mv "$f" "$DIR/$new"
  echo "Tagged: $base -> $new"
done
cd "$HOME/MorinusChartsRepo"
git pull --rebase --autostash || true
git add Hors/*.hor || true
git commit -m "Initial bulk tag ($USER_TAG)" || true
git push || true