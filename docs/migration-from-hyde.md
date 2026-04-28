# Migration runbook

This document will be filled in as M4 lands. Intended structure:

## Pre-migration

1. Back up your current `~/.config` via your existing framework's backup mechanism (or `cp -a ~/.config ~/.config.pre-wired-$(date +%F)`).
2. Commit + push any local changes in your current dotfiles repo.

## Staged transition

1. Clone wired-dots (with submodules for the wallpaper pack): `git clone --recurse-submodules https://github.com/cativo23/wired-dots.git ~/wired-dots`
2. Smoke-test against a disposable prefix: `cd ~/wired-dots && ./install.sh --prefix=/tmp/wired-test`
3. Inspect `/tmp/wired-test/.config/` — confirm symlinks point where you expect.
4. Uninstall the old framework's symlinks: (framework-specific, add steps here as framework integrations land)
5. Full install: `./install.sh`
6. Reboot.

## Rollback

If the reboot doesn't work:
- Boot into a TTY (Ctrl+Alt+F2)
- `cp -a ~/.config/cfg_backups/wired-<latest>/* ~/.config/` — restores pre-install user configs
- For system-level changes (`/etc/`), the `.wired.bkp` sentinels point to original content — manual revert per file
- If still broken: boot from an Arch USB, `chroot` in, and restore from `/home/<user>/.config.pre-wired-*`
