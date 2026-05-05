# wired-dots v2 — Design Spec

**Status**: Draft  
**Date**: 2026-05-04  
**Author**: Carlos Cativo (with brainstorm + critical review by AI agents)  
**Project**: `cativo23/wired-dots` (rebuild from scratch, retain repo name + branding)

---

## 1. Vision

**wired-dots** is a cyberpunk Hyprland setup for Arch Linux. Distributable, opinionated, palette-driven, and inspired (not cloned) by Symphony's runtime theme switching and the nightwire design system.

The CLI binary is `wired`. The project is `wired-dots`.

### Goals

- Reproducible Arch + Hyprland desktop deployable with one TUI-driven installer.
- Runtime theme switching (`wired switch <name>`) with sub-second reload.
- Palette-driven theme generation: one `palette.toml` + shared `envsubst` templates → outputs.
- Hardware support honest about what's tested vs best-effort.
- Maintainable by a single person with a full-time job.

### Non-goals (v1.0.0)

- Arbitrary theme imports from third-party repos (`wired import`) — deferred to v1.3+.
- Wallpaper-driven dynamic theming (`chaos` mode) — deferred to v1.2 pending matugen pre-processing investigation.
- bladerunner / monochrome themes — deferred to v1.1.0.
- Theming for GUI editors (VSCode, Cursor, Obsidian) and chat clients — deferred to v1.1+ if demand exists.
- NVIDIA legacy (Maxwell/Pascal/Fermi/Kepler), GRUB MBR/BIOS, LUKS-encrypted root.

### Anti-patterns explicitly avoided

- **Bundles** in TUI (e.g., `fullstack-dev` pre-grouping). Validated against archinstall, omarchy, EndeavourOS — none ship app bundles in their installers; they create maintenance debt and arbitrary semantic contracts. Replaced by category-grouped multi-select + curated package sets in README.
- **HyDE coupling**: no dependency on HyDE's `wallbash`, P-flag preservation, or deferred OMZ loading. Self-contained.
- **Bleeding-edge scope creep**: hardware support and theme breadth deliberately constrained for v1.

---

## 2. Architecture overview

### Three layers

| Layer | Owner | When it runs | Owns |
|---|---|---|---|
| **1. Installer** (`installer/`) | User runs `./install.sh` | Once, at fresh install | System packages, hardware setup, initial config deploy, system-wide themes (SDDM/GRUB) |
| **2. CLI Runtime** (`cli/`, `bin/wired`) | User day-to-day | Anytime | Theme switching, wallpapers, vibe/focus, reload, repair, uninstall |
| **3. Theme System** (`themes/`, `templates/`, `hooks/`) | Build pipeline + runtime | On `wired switch` | Color generation, app reload coordination |

### High-level data flow

```
User runs: wired switch nervwire
  ↓
cli/lib/build.sh:
  parse themes/nervwire/palette.toml → exports vars
  envsubst < templates/*.tmpl > ~/.config/wired/cache/themes/nervwire/*
  cp themes/nervwire/overrides/* (if any) → cache (overrides win)
  ↓
cli/lib/state.sh:
  ln -sfn cache/themes/nervwire ~/.config/wired/current
  write state.toml
  ↓
cli/lib/hooks-runner.sh:
  for hook in hooks/NN-*.sh; run hook  (numbered priority)
  ↓
Apps reload (kitty SIGUSR1, waybar restart, hyprctl reload, swaync reload, etc.)
  ↓
Notify user via swaync with thumbnail
```

### Repository layout

```
wired-dots/
├── bin/                              # Symlinked to ~/.local/bin
│   └── wired                         # CLI entry point
├── installer/
│   ├── install.sh                    # Top-level entry
│   ├── tui/                          # gum-based wizards (12 screens)
│   ├── phases/                       # 00–10 sequential install phases
│   └── lib/                          # log, detect, safe-symlink helpers
├── cli/
│   ├── wired                         # CLI source (sourced by bin/wired)
│   ├── commands/                     # one file per subcommand
│   └── lib/                          # build, hooks-runner, state, log
├── themes/
│   ├── nightwire/                    # default, soft-neon
│   ├── nervwire/                     # NERV-coded
│   └── chaos/                        # v1.2+ — matugen-driven, gitignored palette
├── templates/                        # envsubst templates per app (~22 files)
├── hooks/                            # NN-app.sh ordered (00 → 50)
├── configs/                          # non-color configs (layout, keybinds, etc.)
├── system/                           # SDDM, GRUB themes (frozen "wired brand")
├── docs/
│   ├── superpowers/specs/            # this file lives here
│   ├── screenshots/
│   ├── architecture.md
│   ├── adding-a-theme.md
│   ├── keybindings.md
│   └── troubleshooting.md
├── tests/
│   ├── arch-container/               # CI smoke test
│   ├── theme-build/                  # palette → output validation
│   └── bats/                         # CLI integration tests with fakes
├── .github/
│   ├── workflows/
│   └── ISSUE_TEMPLATE/
├── CHANGELOG.md
├── VERSION
├── README.md
├── SUPPORT.md                        # supported hardware tiers
├── DOGFOOD.md                        # daily-driver journal during DoD
├── LICENSE                           # MIT
├── install.sh                        # delegates to installer/install.sh
└── uninstall.sh
```

### Runtime state directory

```
~/.config/wired/
├── current → ../../cache/themes/<active>/   # symlink swapped on switch
├── state.toml                                # active theme, mode (vibe/focus), history
└── cache/
    └── themes/
        ├── nightwire/
        │   ├── kitty.conf
        │   ├── waybar.css
        │   └── ... (15 rendered files)
        └── nervwire/
```

App configs reference the symlink (e.g., kitty `include ~/.config/wired/current/kitty.conf`). Switching = atomic symlink update + hooks.

---

## 3. Theme system

### Approach 3 — Palette-driven with optional overrides

Each theme owns:

```
themes/<name>/
├── meta.toml             # name, display, description, variant, strict
├── palette.toml          # SOURCE OF TRUTH (~30 color tokens)
├── wallpapers/           # 3 wallpapers, lowercase numbered
│   ├── 01-*.jpg
│   ├── 02-*.jpg
│   └── 03-*.jpg
└── overrides/            # OPTIONAL, files that win over rendered templates
```

### `palette.toml` schema

```toml
[meta]
name = "nightwire"
display = "Nightwire"
description = "Pure void with soft neon. Based on cativo23/nightwire."
variant = "dark"
strict = true   # enforces nightwire purity (BG #000)

[surfaces]
void          = "#000000"
elevated      = "#0a0a0f"
border        = "#1a1a2e"
border_strong = "#2a2a3e"

[text]
primary   = "#e0e0ff"
secondary = "#9090c0"
muted     = "#606080"

[semantic]
primary  = "#6699ff"  # nightwire blue
success  = "#7aed7a"
info     = "#66ddff"
warning  = "#e8993a"
danger   = "#ff6688"
accent   = "#b266e0"

[ansi]
black = "#000000"; red = "#ff6688"; green = "#7aed7a"; yellow = "#e8993a"
blue  = "#6699ff"; magenta = "#b266e0"; cyan = "#66ddff"; white = "#e0e0ff"
# bright_* variants follow

[wallpaper]
default = "01-void.jpg"
list    = ["01-void.jpg", "02-grid.jpg", "03-circuits.jpg"]
```

### Templates (`envsubst` syntax)

Shared across all themes. Example `templates/kitty.conf.tmpl`:

```
background           ${void}
foreground           ${text_primary}
color0               ${ansi_black}
color1               ${ansi_red}
# ... 16 ANSI colors
cursor               ${semantic_primary}
selection_background ${semantic_accent}
```

**Build step**: `set -a; source <(toml-flatten palette.toml); set +a; envsubst < tmpl > output`. Cached in `~/.config/wired/cache/themes/<name>/` based on palette mtime.

### Override flow (escape hatch)

If `themes/<name>/overrides/<file>` exists, it copies over the rendered output. Rationale: rare cases where a theme needs hand-crafted layout that templates can't express (e.g., a theme with a fundamentally different waybar visual structure).

### Themes shipped in v1.0.0

| # | Name | Variant | BG | Vibe |
|---|---|---|---|---|
| 1 | `nightwire` | dark | `#000000` | Default — soft neon, blue/green/cyan/pink/purple, sibling of nightwire.css design system |
| 2 | `nervwire` | dark | `#0a0a0a` | NERV/Eva — orange + matrix-green + alert-red, aggressive |

v1.1 adds bladerunner + monochrome. v1.2 adds chaos.

### `chaos` mode (deferred to v1.2)

Same Approach 3 pipeline, but `themes/chaos/palette.toml` is generated by matugen from a wallpaper. Pre-processing step (saturate + boost contrast via ImageMagick before matugen) explored in v1.2 to address Material You's tendency toward muted palettes.

---

## 4. Apps theme-managed in v1.0.0 (15)

**WM/Compositor (6)**: hyprland · hyprlock · waybar · rofi · swaync · wlogout  
**Terminal stack (5)**: kitty · ghostty · zsh (plugin colors) · starship · bat  
**Productivity (4)**: btop · fastfetch · yazi · lazygit  

**Plus (conditional)**: terminal editor (nvim/helix/micro/nano) — themed only if user picks one in installer screen 7.5.

**System-wide (deployed but not "in the 15")**: GTK3/4 theme, Kvantum, qt5ct/qt6ct, cursor (phinger-cursors-dark), fonts.

### NOT theme-managed in v1 (installable via BYOP)

GUI editors (VSCode, Cursor, Zed, JetBrains Toolbox), AI tooling (claude-code, opencode, ollama, qwen-code), Discord clients (vesktop), Slack, Thunderbird, Obsidian, mpv, OBS, spicetify-marketplace-bin, extra browsers. Theming for some of these may land in v1.1+.

---

## 5. Installer (Layer 1)

### TUI flow — 12 screens (gum-driven)

1. **Welcome** — banner + intro
2. **Hardware detection** — auto-detect (CPU, GPU, bootloader, WiFi, audio, battery), read-only summary, confirm to continue. Tier-3/unsupported hardware warns or aborts with workaround docs link.
3. **Theme picker** — nightwire (default) | nervwire, with palette swatches preview
4. **Browser** — brave-bin (default) | firefox | chromium | google-chrome | none. Note: Firefox = full pywalfox theming; others = best-effort CSS.
5. **File manager** — dolphin (default) | nautilus | thunar | nemo | pcmanfm | yazi-only
6. **Display manager** — sddm (default, with nightwire Silent theme) | greetd (tuigreet) | none
7. **Keyboard layout** — us (default) | latam,us | es | de | fr | br | gb | ...
8. **Terminal editor** — nvim (default) | helix | micro | nano (theme only) | none
9. **Personal extras (BYOP)** — file (`~/wired-extras.lst` default) | curated multi-select | both | skip. Curated multi-select grouped by: Dev tools / AI tooling / GUI editors / K8s / Communication / Media / Productivity / Browsers extra.
10. **Summary + confirm** — review + warning of disk impact + backup destination
11. **Install progress** — phase-by-phase with spinners + progress bar
12. **Done** — next steps + reboot prompt

### Non-interactive mode (CI / scripted)

```
./install.sh \
  --theme=nightwire \
  --browser=firefox \
  --file-manager=yazi-only \
  --display-manager=greetd \
  --kb-layout=us \
  --editor=nvim \
  --extras=~/wired-extras.lst \
  --noninteractive
```

Partial flags allowed: `./install.sh --theme=nervwire` opens TUI but pre-selects nervwire on screen 3.

### Phases (port from RC3, redesigned UX)

```
00_preflight.sh     — deps, internet, disk space, gum install if missing
01_backup.sh        — snapshot ~/.config/ to ~/.config/cfg_backups/wired-YYYYMMDD-HHMMSS/
02_detect.sh        — GPU, CPU microcode, bootloader (functions return values, no prompts)
03a_pacman_tweaks.sh
03b_core_packages.sh
03c_audio.sh        — pipewire + wireplumber
03d_fonts.sh        — JetBrainsMono, Noto Serif Display, Saira, Shippori, Red Hat Display
03e_bluetooth.sh
03f_aur_packages.sh — yay/paru detect, install BYOP extras with pacman→AUR fallback
04a_gpu_detect.sh
04b_gpu_nvidia.sh   — Turing+ only (Maxwell/Pascal/Fermi/Kepler unsupported)
04c_gpu_amd.sh      — RDNA+
04d_gpu_intel.sh    — Xe/Arc
04e_power.sh        — TLP if laptop
05_wifi.sh
06_symlinks.sh      — deploy configs/ via per-app symlinks (hybrid layout for zsh)
07_theme.sh         — apply chosen theme via `wired switch <name>`
08_display_manager.sh
09_bootloader.sh    — UEFI only (GRUB / systemd-boot / rEFInd)
10a_system_services.sh
10b_xdg_portal_restart.sh
10c_verification.sh
```

State passed to phases via `/tmp/wired-installer.env` (exported vars: `WIRED_THEME`, `WIRED_BROWSER`, etc.).

### `--dry-run` real (not just log lines)

Phases support `DRY_RUN=1` env var. In dry-run, NO writes outside `/tmp`, NO sudo, NO pacman install. Reports what each phase **would** do. Critical for user trust and for capturing edge cases pre-rotura.

---

## 6. CLI runtime (Layer 2)

### Surface in v1.0.0

```
wired switch <name>          Switch to theme
wired list                   List installed themes
wired current                Show active theme + palette
wired tui                    Interactive theme browser (gum-based, with preview)
wired reload                 Re-apply current theme (after edits)
wired remove <name>          Uninstall a theme
wired wallpaper next|prev|random|set <path>
wired vibe                   Toggle to vibe mode (gaps, animations, blur)
wired focus                  Toggle to focus mode (minimal, fast)
wired fix                    Repair broken symlinks + permissions
wired version                Show version
wired help                   Show usage
wired uninstall              Remove wired-dots completely (calls top-level uninstall.sh)
```

Deferred:
- `wired chaos` → v1.2.0 (matugen-driven)
- `wired browse` → v1.2+ (preview-rich theme picker, currently subsumed by `wired tui`)
- `wired import <url>` → v1.3+ (community theme imports, requires standardized format)

### vibe / focus mode

Pure runtime via `hyprctl keyword` calls — no config edits. State persists in `~/.config/wired/state.toml`.

| | vibe (default) | focus |
|---|---|---|
| `gaps_in` | 4 | 0 |
| `gaps_out` | 10 | 0 |
| `general:border_size` | 2 | 1 |
| `decoration:rounding` | 12 | 0 |
| `animations:enabled` | 1 (cyberdeck preset) | 0 |
| `decoration:blur:enabled` | 1 | 0 |
| kitty `background_opacity` | 0.85 | 1.0 |
| waybar | shown | hidden |

Toggle keybind: `SUPER+CTRL+BackSpace` (helper script `wired-toggle-mode` reads state and alternates).

### Other keybindings

```
SUPER+T              wired tui
SUPER+SHIFT+W        wired wallpaper next
SUPER+CTRL+BackSpace wired-toggle-mode (vibe ↔ focus)
```

---

## 7. Shell stack (zsh)

**Decision**: `antidote + getantidote/use-omz + zsh-defer + curated plugins`. Validated against independent benchmarks (rossmacarthur, antidote.sh) and official antidote docs (use-omz is officially recommended since June 2024).

### `~/.config/zsh/wired-defaults.zsh`

```zsh
# Critical path (~30ms)
ANTIDOTE="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
[[ -d $ANTIDOTE ]] || git clone --depth=1 https://github.com/mattmc3/antidote $ANTIDOTE
source $ANTIDOTE/antidote.zsh

# Bootstrap zsh-defer
ZSH_DEFER="$ANTIDOTE/../zsh-defer"
[[ -d $ZSH_DEFER ]] || git clone --depth=1 https://github.com/romkatv/zsh-defer $ZSH_DEFER
source $ZSH_DEFER/zsh-defer.plugin.zsh

# Deferred (after first prompt, no perceived latency)
zsh-defer antidote load ${ZDOTDIR}/.zsh_plugins.txt

# Synchronous starship (cheap)
eval "$(starship init zsh)"

# User layer (sync, user owns weight)
[[ -f $ZDOTDIR/user.zsh ]] && source $ZDOTDIR/user.zsh
[[ -f $ZDOTDIR/user.local.zsh ]] && source $ZDOTDIR/user.local.zsh
```

### `~/.config/zsh/.zsh_plugins.txt`

```
# OMZ dependency layer (REQUIRED FIRST)
getantidote/use-omz

# OMZ stdlib (lazy-loaded by use-omz)
ohmyzsh/ohmyzsh path:lib

# OMZ plugins (cherry-picked, no framework)
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/sudo
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/colored-man-pages

# Modern UX (deferred where applicable)
zsh-users/zsh-completions path:src kind:fpath
zsh-users/zsh-autosuggestions kind:defer
zdharma-continuum/fast-syntax-highlighting kind:defer
Aloxaf/fzf-tab kind:defer
```

**Targets**: real total startup ~150ms, perceived latency <80ms (HyDE-like instant prompt without HyDE coupling). Validated as part of CI performance gate.

### Hybrid file layout (`installer/phases/06_symlinks.sh`)

- `wired-defaults.zsh` → symlink (always wired-managed)
- `.zsh_plugins.txt` → symlink (always wired-managed)
- `user.zsh` → copy ONCE from `.example` template, never overwritten
- `user.local.zsh` → copy ONCE, gitignored, never overwritten

---

## 8. System-level theming

### SDDM (frozen, paleta nightwire)

One bespoke "Silent" SDDM theme with nightwire palette baked in. Installed once at install time. Never changes with `wired switch`. Rationale: SDDM theme reload requires logout — not a runtime-swap candidate. Functions as the project's brand presence on login.

### GRUB / systemd-boot / rEFInd (frozen)

One bespoke GRUB theme (Elegant variant, nightwire palette). Same rationale as SDDM (reboot-only).

### hyprlock (runtime-swappable)

hyprlock is a one-shot binary (each lock invocation reads config fresh from disk). Therefore: each theme ships its own `themes/<name>/overrides/hyprlock.conf` (or it's generated from `templates/hyprlock.conf.tmpl`). Symlink swap on `wired switch` is enough.

---

## 9. Hardware support matrix

`SUPPORT.md` ships with these tiers, documented explicitly:

### Tier 1 — CI verified

- CPU: Intel 8th gen+, AMD Ryzen 1000+
- GPU: Intel Xe / Arc (modern)
- Bootloader: systemd-boot UEFI
- Audio: PipeWire + WirePlumber
- Display: 1080p, 1440p single

### Tier 2 — Tested on Carlos's hardware

- GPU: NVIDIA RTX 30 Mobile (Turing+), AMD RDNA (RX 6000)
- Bootloader: GRUB UEFI, rEFInd UEFI
- Display: dual monitor (DP + HDMI)
- WiFi: Realtek RTL8821CE (DKMS)

**Cadence**: Tier 2 re-validated on every minor release (v1.x.0). Without this calendar, Tier 2 collapses to Tier 3 within 6 months.

### Tier 3 — Best-effort

- NVIDIA Turing+ outside RTX 30
- AMD GCN legacy (RX 400/500)
- Optimus hybrid laptops
- Triple+ monitor setups
- BTRFS / ZFS / LVM root

Issues triaged monthly, no SLA.

### ❌ Unsupported in v1

- NVIDIA Maxwell/Pascal/Fermi/Kepler legacy
- GRUB legacy MBR / BIOS-only systems
- Wayland-incompatible NVIDIA versions
- Dual-boot Windows (untested)
- LUKS-encrypted root (untested)

Installer detects Tier 3 → warning + docs link. Detects Unsupported → aborts with clear message + manual workaround suggestion.

---

## 10. Quality gates

### 10.1 CI pipeline (`.github/workflows/ci.yml`)

Runs on every push and PR. 5 parallel jobs:

**`lint`** (~30s)
- `bash -n` on every `.sh`
- `shellcheck --severity=warning`
- markdown lint (`mdl`)
- TOML schema validation (`taplo`)
- secret scan (`gitleaks`)

**`theme-build`** (~1min)
- Build each theme with `cli/lib/build.sh`
- Validate `palette.toml` schema (required tokens, hex format)
- Verify outputs are valid (jq for JSON, css-validator for CSS, tomlq for TOML)
- Assert no hex literals leak in outputs (all colors come from palette)

**`arch-smoke`** (~3min)
- archlinux:latest container
- Install minimal deps (jq, gum, envsubst, gitleaks)
- Run installer in `--dry-run --noninteractive`
- Verify phases NEVER write outside `/tmp` in dry-run
- Verify phases output parsable summary
- **Idempotence test**: run installer 2× in same container, diff filesystem, must be empty (excluding logs/timestamps)
- **Backup/rollback test**: simulate previous install, run installer, verify `~/.config/cfg_backups/` contains restorable snapshot

**`bats-cli`** (~1min)
- BATS test suite with fakes for `hyprctl`, `gsettings`, `swaync-client`
- Cover `wired switch`, `wired wallpaper next`, `wired vibe`/`focus`, `wired fix`
- Verify hooks fire in correct order
- Verify state.toml updates atomically

**`perf-gate`** (~30s)
- `hyperfine --runs 20 'wired switch nightwire nervwire'`
- Fail CI if p95 > 1.2s
- `hyperfine --runs 20 'cli/lib/build.sh themes/nightwire'`
- Fail CI if p95 > 500ms
- Bash compat matrix: 5.1 + 5.2 (matrix in workflow)

### 10.2 Dummy box validation (192.168.0.234)

**Path-based trigger**: if PR diff matches `^(installer|phases|setup\.sh)`, dummy run is **mandatory** before merge to `develop`. Other PRs: green CI is sufficient.

**Automation**: packer + qemu builds a "golden Arch base" image (cached, ~5min). Provides `make dummy-test`:

```bash
make dummy-test
# Behavior:
# 1. Revert dummy snapshot to clean Arch
# 2. scp current branch to dummy
# 3. ssh: ./install.sh --noninteractive (with test config)
# 4. ssh: reboot, wait for SDDM
# 5. ssh: hyprland --test-mode (smoke), wired switch nervwire
# 6. scp logs back, screenshot
# 7. Print pass/fail summary
```

Pre-merge checklist (manual confirmation, supplements automation):

- [ ] `make dummy-test` passes
- [ ] Visual check: SDDM appears, hyprland inits, waybar visible
- [ ] `wired switch nervwire` + visual change confirmed
- [ ] `wired focus` + `wired vibe` roundtrip
- [ ] `wired wallpaper next` x3
- [ ] Final screenshot pasted in PR

### 10.3 Release process

**Branch model** (GitFlow):
```
main ← release/vX.Y.Z ← develop ← feature/*|fix/*
```

**Versioning**: SemVer with RC tags (`v1.0.0-rc1`, `rc2`, then `v1.0.0`).

**Pre-tag gate** (`.github/workflows/release-dry-run.yml`):
- Triggered manually before tag creation
- Runs full CI suite
- Runs dummy-test
- Generates changelog draft from commits since last tag
- **Manual approval required** before creating actual tag

**Auto-release** (`.github/workflows/release.yml`):
- Triggered on push of `v*.*.*` tag
- Extracts changelog section for the version
- Builds tarball `wired-dots-vX.Y.Z.tar.gz`
- Creates GitHub release with changelog + tarball

**Post-tag smoke** (`.github/workflows/release-smoke.yml`):
- Triggered on release publish
- Downloads the published tarball (NOT repo)
- Installs in clean container
- Verifies `wired --version` matches tag
- Catches corrupt releases before users hit them

**Yank procedure** (documented in `docs/release-procedure.md`):
1. Delete GitHub release
2. Delete git tag (local + remote)
3. Publish `vX.Y.Z+1` with fix
4. Announce yank in CHANGELOG and GitHub Discussion

**`--channel` flag** in installer: `stable` (default) | `rc` allows early adopters to opt-in without manual git checkout.

### 10.4 Definition of Done — v1.0.0

**Functional**:
- [ ] Installer completes fresh Arch → wired desktop in <15min
- [ ] All 12 TUI screens functional + non-interactive flags
- [ ] 2 themes (nightwire + nervwire) switching <1s (CI-enforced via perf-gate)
- [ ] 15 apps theme-managed reload OK on switch
- [ ] vibe ↔ focus toggle without restart
- [ ] wallpaper next/prev/random/set work
- [ ] `wired fix` repairs broken symlinks
- [ ] `wired uninstall` restores backup AND tested end-to-end (no fear-of-trying)

**Hardware**:
- [ ] Tier 1 green in CI
- [ ] Tier 2 manual validation on atlas (Intel) + desktop (NVIDIA)
- [ ] Dummy box (192.168.0.234) full pass via `make dummy-test`

**Docs**:
- [ ] README with install instructions, screenshots, supported matrix
- [ ] SUPPORT.md with tier table
- [ ] CHANGELOG with entries `v1.0.0-rc*` + `v1.0.0`
- [ ] `docs/keybindings.md`
- [ ] `docs/troubleshooting.md` with FAQ
- [ ] `docs/adding-a-theme.md` (step-by-step guide for contributors)
- [ ] `docs/release-procedure.md` (yank + release runbook)

**Quality**:
- [ ] shellcheck warning-free across all `.sh`
- [ ] 1+ screenshot per theme in `docs/screenshots/`
- [ ] 1 GIF or asciinema of `wired switch` in README
- [ ] **30+ days daily-driver on atlas** with daily entries in `DOGFOOD.md` (1 line + bug count). Without DOGFOOD entries, the 30 days don't count.

### 10.5 Mitigation triggers — executable, not aspirational

**`.github/workflows/maintainer-health.yml`** (cron: weekly Mondays):
```yaml
- name: Check Carlos commit cadence
  run: |
    if [[ $(git log --since=21.days --author=cativo23 --oneline | wc -l) -eq 0 ]]; then
      gh issue create \
        --title "🛑 Burnout check: 3 weeks no commits" \
        --label burnout-check --assignee cativo23
    fi
```

**`.github/workflows/issue-triage.yml`** (cron: daily):
```yaml
- name: Stale issue scan
  run: |
    count=$(gh issue list --label needs-response --json updatedAt | \
            jq '[.[] | select(.updatedAt | fromdateiso8601 < now - (7*86400))] | length')
    [[ $count -ge 3 ]] && echo "::warning::3+ stale issues — triage focus week needed"
```

**Quarterly calendar review** (manual, not workflow):
- Star count plateau (50–100 after 3 months)
- "chaos mode looks meh" feedback (when v1.2 lands)
- Hardware tier accuracy

These are NOT auto-measurable; review every 3 months and decide adjustments.

### 10.6 Observability roadmap (v1.x)

**Critical gap identified**: spec is over-designed on gates, under-designed on observability. For v1.x:

- **Telemetry opt-in**: anonymous installer crash reports (sentry-cli, glitchtip self-hosted, or auto-created GitHub issues with sanitized logs). One hour of log aggregation > ten hours of tier matrix maintenance.
- **Auto-merge selectivo**: GitHub Actions auto-merge for PRs labeled `auto-merge-safe` (typically docs, README, non-installer content). Estimated savings: 5h/week.

Both deferred to v1.x but documented here so they're not lost.

---

## 11. Roadmap

| Version | Theme adds | Feature adds | Risk addressed |
|---|---|---|---|
| **v1.0.0 — Foundation** | nightwire, nervwire | TUI installer, CLI runtime, vibe/focus, wallpaper, palette-driven build, hooks system | Maintenance bankruptcy ↓ via small surface |
| **v1.1.0 — Polish** | bladerunner, monochrome | Optimus hybrid support (Tier 2), 5 more theme-managed apps via demand | Adoption signal validation |
| **v1.2.0 — chaos (experimental)** | chaos | matugen + ImageMagick saturate-preprocessor; default still handcrafted; UX clearly experimental | Pre-mortem failure #4 mitigation |
| **v1.3.0 — community** | — | `wired import <url>`, theme schema published, observability telemetry | Reactive to traction |
| **v2.0.0 — TBD** | TBD | TBD breaking changes | Far future |

---

## 12. Risks (from pre-mortem)

| # | Risk | Likelihood × Impact | Mitigation |
|---|---|---|---|
| 1 | Maintenance burden bankruptcy (solo maintainer + bleeding-edge ecosystem) | HIGH × HIGH | Scope limited to apps Carlos uses daily; tier matrix honest about untested combos; mitigation triggers automated; auto-merge selectivo planned |
| 2 | Hardware edge case bricks user (NVIDIA + GRUB legacy + dual monitor) | HIGH × HIGH | Tier 1/2/3 documented; unsupported list explicit; `--dry-run` real, not log-only; CI mocks `lspci`/`dmidecode`; post-tag smoke catches release-time regressions |
| 3 | Adoption cliff vs omarchy/Symphony (winner-takes-all market) | HIGH × MEDIUM | Reframe accepted: ship serious infra but expect personal-showcase-level adoption; success measured by Carlos's daily use, not stars |
| 4 | `chaos` mode aesthetic mismatch (matugen → Material You muted, not cyberpunk neon) | MEDIUM × MEDIUM | Deferred to v1.2; pre-investigation of saturate-preprocessor required; ships marked experimental; default stays handcrafted |

---

## 13. Open questions

None at this point. All major decisions have been made. Items not in this spec are deferred (chaos pipeline details, telemetry endpoint choice, etc.).

---

## 14. Decision log (compressed)

- **Repo strategy**: delete + rebuild `cativo23/wired-dots`, retain name + branding, lose RC3 git history.
- **Distribution ambition**: serious distributable, scope-constrained for v1 (per pre-mortem).
- **Theme system**: Approach 3 (palette + envsubst templates + optional overrides).
- **Theme breadth**: 2 themes v1, expanding to 5 by v1.2.
- **Wallpapers**: 3 per theme, lowercase paths, `themes/<name>/wallpapers/`. Chaos pool inside `themes/chaos/wallpapers/` (no top-level pack).
- **Themes are pluggable, vibe-aligned, not nightwire-strict**.
- **Symphony positioning**: inspired but not cloned. nightwire (the design system) is mirrored to `palette.toml` manually (option B), no submodule coupling.
- **Installer UX**: TUI with `gum` (12 screens) + `--noninteractive` flags + `--dry-run` real.
- **Hardware**: port logic from RC3, redesign UX as TUI.
- **CLI**: `wired` binary, project name `wired-dots`.
- **Bundles in TUI**: dropped (validated against omarchy/archinstall — none ship them).
- **Shell**: antidote + use-omz + zsh-defer + curated plugins.
- **Display manager**: SDDM default + greetd alternative.
- **Versioning**: SemVer + RC tags + GitFlow.
- **Validation cadence**: dummy box automated via packer-qemu, path-triggered for installer changes.

---

## Appendix A — Brainstorm session

This spec is the result of a 19-question structured brainstorm session held 2026-05-04. Two adversarial reviews were performed:

1. **The Fool / pre-mortem** identified bundles as scope bloat (validated against archinstall, omarchy, EndeavourOS) and surfaced 4 failure narratives (maintenance bankruptcy, hardware edge cases, adoption cliff, chaos aesthetic mismatch) with mitigation tactics.
2. **DevOps engineer review** of Section 10 (quality gates) identified gaps in CI (BATS, idempotence, perf gate, secret scan) and dummy box automation (packer-qemu, path-trigger) — all integrated into this spec.

Brainstorm artifacts retained at `.superpowers/brainstorm/<session-id>/content/section-*.html` (gitignored).
