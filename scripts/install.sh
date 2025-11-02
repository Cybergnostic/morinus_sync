#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${HOME}/MorinusChartsRepo"
HORS_DIR="${REPO_DIR}/Hors"
MORINUS_DIR="${HOME}/projects/MorinusWin"
MORINUS_HORS="${MORINUS_DIR}/Hors"

# --- 1) Detect package manager and install deps ---
detect_pm() {
  if command -v dnf >/dev/null 2>&1; then echo dnf; return
  elif command -v apt-get >/dev/null 2>&1; then echo apt; return
  elif command -v pacman >/dev/null 2>&1; then echo pacman; return
  elif command -v zypper >/dev/null 2>&1; then echo zypper; return
  else echo "unknown"; return
  fi
}

PM=$(detect_pm)
echo "[*] Package manager: $PM"

case "$PM" in
  dnf)
    sudo dnf install -y git git-lfs inotify-tools
    ;;
  apt)
    sudo apt-get update
    sudo apt-get install -y git git-lfs inotify-tools
    ;;
  pacman)
    sudo pacman -Sy --noconfirm git git-lfs inotify-tools
    ;;
  zypper)
    sudo zypper install -y git git-lfs inotify-tools
    ;;
  *)
    echo "[-] Unsupported distro. Please install git, git-lfs, inotify-tools manually."
    ;;
esac

# --- 2) Git LFS enable ---
git -C "$REPO_DIR" lfs install

# --- 3) Ensure repo structure ---
mkdir -p "$HORS_DIR"

# --- 4) Link Morinus Hors -> repo Hors (idempotent) ---
mkdir -p "$MORINUS_DIR"
if [ -L "$MORINUS_HORS" ]; then
  echo "[*] Symlink already exists: $MORINUS_HORS"
elif [ -d "$MORINUS_HORS" ] && [ -z "$(ls -A "$MORINUS_HORS")" ]; then
  rmdir "$MORINUS_HORS"
  ln -s "$HORS_DIR" "$MORINUS_HORS"
  echo "[+] Linked empty Hors dir to repo"
elif [ -d "$MORINUS_HORS" ]; then
  # Move existing files into repo, then link
  echo "[*] Moving existing Hors files into repo..."
  shopt -s nullglob
  mv "$MORINUS_HORS"/* "$HORS_DIR"/ || true
  rmdir "$MORINUS_HORS" || true
  ln -s "$HORS_DIR" "$MORINUS_HORS"
  echo "[+] Linked Hors dir to repo and migrated files"
else
  ln -s "$HORS_DIR" "$MORINUS_HORS"
  echo "[+] Created symlink for Hors"
fi

# --- 5) Configure safe git defaults for auto-pull/push ---
git -C "$REPO_DIR" config pull.rebase true
git -C "$REPO_DIR" config rebase.autoStash true

# --- 6) Install user-level systemd service ---
bash "${REPO_DIR}/scripts/setup_service.sh"

echo "[✓] Install complete."
echo "    Service status: systemctl --user status hors-sync"