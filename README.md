# Morinus Hors Sync

Automatic filename tagging and Git sync for Morinus `.hor` files.

## What it does
- Watches `~/MorinusChartsRepo/Hors` for `.hor` files
- Renames new files to `name_<username>.hor`
- `git pull` → `git add/commit` → `git push`
- Runs as a user-level systemd service
- Symlinks Morinus folder: `/home/$USER/projects/MorinusWin/Hors` → `~/MorinusChartsRepo/Hors`

## Quick start (first machine)
```bash
git clone <YOUR_REPO_URL> ~/MorinusChartsRepo
bash ~/MorinusChartsRepo/scripts/install.sh
```

## Add another machine

```bash
git clone <YOUR_REPO_URL> ~/MorinusChartsRepo
bash ~/MorinusChartsRepo/scripts/install.sh
```

## Verification Steps (2-3 mins)

```bash
# 1. Set repo remote (if not set yet) and pull LFS
cd ~/MorinusChartsRepo
git remote -v            # should show your private GitHub URL
git lfs install

# 2. Install & start service
bash scripts/install.sh
systemctl --user status hors-sync   # should be "active (running)"

# 3. Smoke test
touch ~/projects/MorinusWin/Hors/TestClient.hor
sleep 2
ls ~/projects/MorinusWin/Hors
# Expect: TestClient_<your-username>.hor
```

## Service Control & Logs

```bash
journalctl --user -u hors-sync -f   # live logs
systemctl --user restart hors-sync
systemctl --user stop hors-sync
```

## Git Authentication

* Prefer SSH remote to avoid password prompts:
  ```bash
  git remote set-url origin git@github.com:<you>/<repo>.git
  ```
* If using HTTPS, set up a PAT or credential helper for automated pushing

## Persistent Service After Reboot

Some distros/servers need lingering enabled for user services to persist:

```bash
loginctl enable-linger "$USER"
systemctl --user enable hors-sync
```

## One-time Setup: Tag Existing Files

To ensure consistent naming from day one:

```bash
bash scripts/tag_existing_once.sh
```

## Notes

* Keep the repo **private** (client data).
* Uses Git LFS for `*.hor`.
* Files are renamed automatically: e.g., `Milan1985.hor` → `Milan1985_jovan.hor`
* Git LFS handles binary storage efficiently
* Service: `systemctl --user status hors-sync` / `start` / `stop` / `enable`