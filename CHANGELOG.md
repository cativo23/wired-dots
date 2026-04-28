# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0-rc2] — 2026-04-27

### Added

- Wallpaper pack as a git submodule under `source/wallpapers/pack/` (shared with `cativo23/wallpapers.git`, also used by `my-hyde-dotfiles`). Replaces the dark gradient placeholder with 13 curated Tokyo Night images. Quick Start now requires `--recurse-submodules`.
- Persistent wallpaper symlink at `~/.config/wired-dots/current` (HyDE-style). Hyprland exec-once resolves the symlink at session start; user selections via `wallpaper next/prev/set` update it and survive reboots.
- `bin/wallpaper` rewritten with `set` / `next` / `prev` / `restore` / `show` subcommands, lockfile under `$XDG_RUNTIME_DIR/wired-dots/`, and `awww-daemon --format xrgb` invocation matching upstream conventions.
- `uninstall.sh` now actually does what it advertised: removes repo symlinks from `~/.config/*` and `~/.local/bin/*`, restores the latest backup from `~/.local/share/wired-dots/backups/<TS>/`, prints sentinel files and direct-deploy /etc artifacts with manual revert hints. Honors `DRY_RUN=1`. 11 bats tests cover symlink-only removal, idempotence, and full-flow.

### Fixed

- **Wallpaper invisible after install**: `06_symlinks.sh activate_waybar_layout` was generating `style.css` by `cat`-ing nonexistent `theme.css` + `user-style.css`. Now copies from `styles/cyberdeck-nerv.css` per spec, plus `defaults.css` for the local `@import` to resolve. Waybar now renders cyberdeck-nerv on first install.
- **Shipped wallpapers never copied**: `deploy_wallpapers` used `compgen -G` with brace expansion that only ever tested `*.jpg` (compgen takes one pattern). Replaced with `find` + `mapfile`. Fallback magick gradient renamed to `tokyo-night-default.png` to align with userprefs.conf reference.
- **Wallpaper exec-once silently failed**: `pgrep -x awww-daemon || awww-daemon` only started the daemon, never applied an image. Replaced with `wallpaper set ~/.config/wired-dots/current`. The `bin/wallpaper` wrapper handles the daemon guard internally.
- **`exec-once = wallpaper …` couldn't find the script**: SDDM-spawned Hyprland inherited a minimal PATH that excluded `~/.local/bin`. Added `env = PATH,$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin` to `userprefs.conf`. Same fix unblocks future binds calling other repo scripts (`screenshot.sh`, `cliphist-rofi`, etc.).
- **Phase 03f killed by single bad AUR package**: dropped `pwvucontrol` (broken upstream against current pipewire — `libspa-0.8.0` references renamed `spa_pod_builder.{data,size}` fields). `pavucontrol` is already in `core.lst` and covers the same role. Per-package iteration in 03f tracked separately as #7.
- **Dead duplicate code**: removed `deploy_waybar_styles` in `06_symlinks.sh` and the `source/assets/waybar-styles/` directory it copied from — both shipped the same content twice and nothing else referenced the secondary copy.

### CI

- shellcheck workflow now ignores `zsh/` (shellcheck doesn't grok zsh, was producing SC2148/SC2034 false positives) and `source/wallpapers/pack/` (foreign repo).
- shellcheck SC2140 fix on the magick gradient quoting.

## [1.0.0-rc1] — 2026-04-24

### Added

- RC fixes: conditional display manager verification (DISPLAY_MANAGER-aware), correct Intel VA-API driver selection per GPU generation, legacy NVIDIA documentation (NVIDIA-LEGACY.md)

### Fixed

- **Critical**: orchestrator now re-runs detection in its own shell scope after the 02/04a phases. `run_phase` execs phase scripts as subprocesses, so `WIFI_MODULE`, `BOOTLOADER`, `GPU_TYPE`, `GPU_CMDLINE`, and `KERNELS` exports were lost — causing WiFi setup and bootloader patching to silently skip on real installs
- `--gpu=` overrides now propagate correctly through dry-run routing
- `networkmanager` package name corrected (was `NetworkManager`) in verification
- `02_detect.sh` detect_phase no longer runs as sourcing side-effect
- Removed duplicate service enable from `08_sddm.sh`/`08_greetd.sh` (owned by `10a`)
- Removed `sddm` from `aur.lst` (official repo package)

## [0.3.0-dev] — 2026-04-24

### Added

- Phase 01: timestamped config backup before symlinking
- Phase 03a: idempotent pacman.conf patch (Color, ILoveCandy, ParallelDownloads) + NVIDIA pacman hook
- Phase 03b–03f: package installers for core, pipewire audio, fonts, bluez bluetooth, and AUR packages
- Phase 04a–04d: GPU detection and driver setup for NVIDIA (Turing+), AMD (RDNA), and Intel (Xe/Arc)
- Phase 05: WiFi driver handling (in-tree detection, RTL8821CE DKMS opt-in)
- Phase 06: full config deployment via symlink_safe (DRY_RUN + ON_CONFLICT aware)
- Phase 07: GTK + cursor theme via gsettings (Tokyonight-GTK-BL, phinger-cursors-dark)
- Phase 08: SDDM and greetd display manager setup with tuigreet/uwsm
- Phase 09: GRUB cmdline patching with GPU kernel params (idempotent)
- Phase 10a: system service enabling (NetworkManager, bluetooth, seatd, display manager)
- Phase 10b: XDG desktop portal restart after config deploy
- Phase 10c: post-install verification with summary box
- 118 bats unit tests covering all phase scripts and global helpers
- Initial repo scaffolding (M0): directory structure, docs skeletons, CI workflows, placeholder entry scripts.

### Changed

- VERSION bumped to 0.3.0-dev

[Unreleased]: https://github.com/cativo23/wired-dots/compare/HEAD
