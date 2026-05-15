# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] — 2026-05-15

First patch release. Eleven fixes from live VM testing that revealed gaps the original hardware validation didn't surface (dummy box only checked waybar + boot, never opened a real Qt/GTK app session).

### Added
- **zsh productivity plugins shipped by default** — autosuggestions (gray inline predictions), syntax-highlighting (live command coloring), history-substring-search (Up/Down filter by substring). Users get the modern shell experience out of the box.
- **Base Latin + Cantarell UI fonts** in `core.lst` (`ttf-dejavu`, `ttf-liberation`, `cantarell-fonts`). Removes the dependency on AUR fonts loading correctly for basic text rendering.
- **`inetutils`** for `hostname` command (used by waybar nerv module).

### Fixed
- **Hyprland error popup on every login** — `misc:vfr` was removed upstream; cleaned out of all three workflow configs.
- **rofi launcher would not render** — Tokyo Night theme had three classes of rasi syntax errors (CSS-style `border` shorthand with `@reference`, `color:` instead of `text-color:`, unsupported `>` child combinator). Theme rewritten.
- **Qt apps rendered all text as empty boxes (`.notdef` tofu)** — qt6ct/qt5ct shipped with only `fixed=` font in binary `@Variant` format. Now ships both `general=` and `fixed=` in plain-text `QFont::toString()` format (Cantarell for UI, CaskaydiaCove Nerd Font Mono for monospace).
- **KDE apps (Dolphin, Kate, kwallet) showed dark text on dark backgrounds** — `~/.config/kdeglobals` was missing entirely; without it KColorScheme falls back to Breeze light-mode defaults and ignores the Kvantum/qt6ct color chain. Now shipped at `home/.config/kdeglobals`.
- **Kvantum Tokyo Night theme applied no colors** — the AUR package `kvantum-theme-tokyo-night` (referenced in `aur.lst`) has never existed in AUR. Real theme assets (`TokyoNight.kvconfig` + `TokyoNight.svg`) now vendored directly in the repo.
- **GTK apps used the default Adwaita light theme regardless of settings** — modern Wayland GTK apps read theme from `gsettings`, not `settings.ini`. Phase 07 now installs the Tokyo-Night theme to `~/.local/share/themes/` and sets the canonical gsettings keys.
- **`notify-send -u critical` notifications had no urgency styling** — `swaync/style.css` used `.urgent` (a dunst class name) where swaync expects `.critical`. Renamed.

### Hardened
- **AUR build failures now fail loud** — phase 03f tracks every AUR package and reports failed builds at the end of install, with a list written to `~/.cache/wired-dots/aur-failed.log`. Previously builds failed silently and the install reported success despite missing themes/fonts.
- **Dropped phantom AUR reference** to `kvantum-theme-tokyo-night` (never existed in AUR).

## [1.0.0] — 2026-05-15

First stable release. Built incrementally through five release candidates with live hardware validation on an AMD Bobcat / Radeon HD 7340 laptop. No new functional changes vs. `1.0.0-rc5`; this tag simply promotes the validated rc5 tree to stable.

### Release highlights

- Hyprland-based Wayland desktop with the Tokyo Night palette throughout (waybar, kitty, starship, hyprlock, fastfetch, SDDM, GRUB).
- Idempotent 20-phase installer (`scripts/00_preflight.sh` → `scripts/10c_verification.sh`) covering hardware detection, packages, audio, fonts, bluetooth, AUR, GPU drivers (NVIDIA/AMD/Intel), power management (TLP), WiFi, symlinks, theme, SDDM, bootloader theme, services, XDG portals, verification.
- User-facing install flags: `--kb-layout`, `--with-browser`, `--with-file-manager`, `--with-tlp`. Choices persist to `~/.cache/wired-dots/user-choices.conf` for reproducible re-runs.
- File-level symlink layout for `~/.config/waybar/` and `~/.config/zsh/` so user edits to non-managed files survive every `./install.sh` run.
- Post-install verifier (`10c`) reports both packages and managed paths; accepts whole-dir symlinks and file-level layouts so users can pick either pattern.
- Hardware-aware TLP delivery: charge thresholds only written on devices that support them; PPD masked (not just disabled) to prevent D-Bus re-activation.
- Optional opt-in modules documented in `docs/optional-modules.md` (Claude Code waybar module, hyprlock profile picture, etc.).
- 39 bats tests covering install flags, symlinks, services, verification, zsh-split, GPU phases, theme, bootloader, preflight, backup, and waybar static smoke. CI runs them on Ubuntu and an Arch container.

See the `1.0.0-rcN` entries below for the incremental change history.

## [1.0.0-rc5] — 2026-05-15

Two targeted fixes from the rc4 validation cycle.

### Fixed

- **SDDM Silent `rei` variant now correctly applied** — previous installs silently fell back to the default preset because the variant-selection override was written to a location the theme doesn't read. The installer now sets the variant in the right place and removes the stale override left by rc3/rc4.
- **GRUB Elegant `mojave-float-left-dark` theme now installed** — the README promised this since rc1 but phase 09 had no install code. The theme is now git-cloned at tag `2025-03-25` and installed via upstream's `install.sh`, with a single `grub-mkconfig` run at the end capturing both the cmdline patch and the theme path.

## [1.0.0-rc4] — 2026-05-14

Post-rc3 validation cycle — 4 targeted fixes from the rc3 audit findings.

### Added

- **`~/.local/bin` on PATH** — `wired-defaults.zsh` now prepends `~/.local/bin` automatically, so wired-dots helper scripts (`screenshot.sh`, `wallpaper`, `cliphist-rofi`, `power-profile-switch`) are reachable from a terminal, not just Hyprland keybinds.

### Fixed

- **TLP killed by PPD re-activation at first boot** — `power-profiles-daemon` was D-Bus-activated at boot even after `systemctl disable` because the socket unit remained enabled. The installer now masks PPD unconditionally when `--with-tlp` is selected, preventing re-activation.
- **Home dotfiles below top level never deployed** — `link_home_dotfiles` used `find -maxdepth 1`, silently skipping nested files like `home/.config/uwsm/env`. Now the full subtree is walked.
- **Post-install verifier false positives for waybar/zsh** — the `10c` verifier reported `~/.config/waybar` and `~/.config/zsh` as "missing or broken" when they were correctly installed as file-level symlink layouts (introduced in rc3). Verifier now accepts both layouts.

## [1.0.0-rc3] — 2026-04-28

The "audit cycle" — Carlos asked for an honest review of what was personal-Carlos noise vs reusable framework, plus the visible waybar bugs that had been broken since rc1. Result: 7 focused PRs that strip the personal layer, parameterize the install, and add a static smoke test that catches the bug class in CI.

### Added

- **Waybar built-in module configs** — eight new files (`cpu`, `memory`, `temperature`, `backlight`, `battery`, `pulseaudio`, `idle_inhibitor`, `clock`) with Tokyo Night Nerd Font glyphs and click handlers wired to plain CLI tools (`pamixer`, `brightnessctl`, `playerctl`). No `hyde-shell` dependency.
- **Installer choice flags** — `--kb-layout=us|latam,us|es|fr|de|br|gb` (default `us`), `--with-browser=brave-bin|firefox|chromium` (default `brave-bin`), `--with-file-manager=dolphin|nautilus|thunar|nemo|pcmanfm-gtk3` (default `dolphin`). Interactive prompt when stdin is a tty; `--noninteractive` skips. Choices persist to `~/.cache/wired-dots/user-choices.conf`. New phase `02b_user_choices.sh` writes a Hyprland-side `local-overrides.conf` defining `$BROWSER`, `$FILE_MANAGER`, and the `input { kb_layout = … }` block; keybindings dispatch via Hyprland variables. Package→binary translation table (`brave-bin→brave`, `pcmanfm-gtk3→pcmanfm`).
- **Hardware-aware TLP** (`--with-tlp`) — finally actually does what the flag advertised since rc1. New phase `04e_power.sh` installs the base config, detects `/sys/class/power_supply/BAT?/charge_control_*_threshold` and writes a charge-threshold overlay only on hardware that supports it. `03b` filters PPD out of the install list and adds `tlp + tlp-rdw`. `10a` swap_power_service disables PPD, enables tlp.
- **zsh defaults split** — three layers now: `wired-defaults.zsh` (framework, refreshed every install), `user.zsh.example` (one-time copy, user-owned thereafter), `user.local.zsh.example` (gitignored secrets). Carlos's `cdp/cdw/lsp/lsw` aliases + `mkpersonal/mkwork/archive_project` ship as the starter `user.zsh` content; user edits survive future installs.
- **Waybar smoke test in CI** (`tests/test_waybar_smoke.bats`) — pure jq + grep static checks against the bug class that hit rc1 and rc2: `$XDG_CONFIG_HOME` literal in includes, empty `format-icons` arrays, `{}+named-placeholder` mixing, dead `bin/` references. 10 tests, ~30 lines apiece. None require waybar to run.
- **`docs/optional-modules.md`** — recipes for re-adding the Claude Code waybar module and a profile picture in hyprlock for users who want them.

### Fixed

- **Waybar custom modules silently broken since rc1**: `include` paths used `$XDG_CONFIG_HOME` but Hyprland-launched waybar inherits no `XDG_CONFIG_HOME` from SDDM. Every include silently failed, every custom module rendered as an unconfigured name. Switched to `$HOME/.config/waybar/*` which is always set.
- **`custom/swaync` format error on libfmt 10+**: `"format": "{icon} {}"` mixes positional and named placeholders. Replaced `{}` with `{text}`.
- **Mediaplayer empty fallback**: shows `󰐎 idle` when no MPRIS player is active so the slot has visible state.
- **`custom/gpuinfo` invisible on AMD without `gpu_busy_percent`**: rewrote exec script to always emit a non-empty string (`n/a` when no GPU usage interface).
- **Spacing too tight in the right cluster** (10 modules in one panel): bumped per-module padding `0 4px → 0 7-8px`, font-size `10 → 12px` on icon-bearing modules, added missing `#custom-swaync` and `#custom-uptime` selectors.
- **TLP `DISK_DEVICES` hardcoded** to Carlos's disk layout: removed (TLP auto-discovers `/sys/block` when absent). **Charge thresholds for `BAT0`** moved to a hardware-gated overlay file (only written if the kernel exposes the interface).
- **`bindkey -e` commented as "Vi keys"** when it's actually emacs: corrected.

### Changed

- **Waybar layout: file-level symlinks** (no more whole-dir symlink + cp-into-source). `~/.config/waybar/` is a real directory; subdirs and the active layout/style/defaults are symlinks pointing at canonical files under `repo/waybar/`. Switching layouts post-install: `ln -sfn layouts/<other>.jsonc ~/.config/waybar/config.jsonc`.
- **zsh layout: hybrid file-level symlinks** (no more whole-dir symlink). `~/.config/zsh/` is a real directory; `.zshrc` and `wired-defaults.zsh` symlinked, `user.zsh` and `user.local.zsh` one-time-copied. Migration path: existing dir-symlink installs auto-upgrade on the next `./install.sh`.

### Removed

- **Personal assets baked into the default ship**:
  - `bin/waybar-claude-code` + `waybar/modules/custom-claude-code.jsonc` (Claude API integration; recipe in `docs/optional-modules.md`)
  - `hypr/hyprlock/backgrounds/profile_square.png` (personal photo); the silent-rei layout's image block is now commented out with opt-in instructions
  - `fastfetch/logo/pokemon_logo.txt` → replaced with `wired-dots.txt`, a Tokyo Night ANSI banner
  - `waybar/user-style.css` (orphan file, never `@import`'d)
- **`pwvucontrol`** dropped from `aur.lst` — broken upstream against current pipewire libspa. `pavucontrol` (already in `core.lst`) covers the same role.
- **`nautilus` and `dolphin`** — both were shipped unconditionally. Now driven by `--with-file-manager=…`.
- **`brave-bin`** — was shipped unconditionally. Now driven by `--with-browser=…`.

### CI

- New `arch-test.yml` dependency: `jq` (used by the waybar smoke test).
- Existing `ubuntu` runner already has jq; nothing else changed.

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
