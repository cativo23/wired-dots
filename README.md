<div align="center">

```text
 ██╗    ██╗██╗██████╗ ███████╗██████╗
 ██║    ██║██║██╔══██╗██╔════╝██╔══██╗
 ██║ █╗ ██║██║██████╔╝█████╗  ██║  ██║
 ██║███╗██║██║██╔══██╗██╔══╝  ██║  ██║
 ╚███╔███╔╝██║██║  ██║███████╗██████╔╝
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝
                    -dots
```

# wired-dots

**A cyberpunk Hyprland setup for Arch — Tokyo Night aesthetic, one script from fresh install to NERV-grade desktop.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-5046e4?style=flat)](https://hyprland.org/)
[![ShellCheck](https://img.shields.io/badge/shellcheck-passing-brightgreen?style=flat)](https://github.com/cativo23/wired-dots/actions)

> **Status:** v0.1.0-dev — scaffolding. Not installable yet. See [Roadmap](#roadmap).

</div>

---

## Gallery

_Screenshots land here once the installer deploys a working desktop._

## Quick Start

```bash
# NOT YET FUNCTIONAL — pending M2+
git clone https://github.com/cativo23/wired-dots.git ~/wired-dots
cd ~/wired-dots
./install.sh
```

## What you get

- Hyprland compositor with Tokyo Night palette
- Waybar cyberdeck-nerv layout
- swaync notifications, rofi launcher, awww wallpaper daemon
- Hardware-agnostic installer: GPU (Intel/AMD/NVIDIA), bootloader (GRUB/systemd-boot/rEFInd), laptop or desktop
- Zero external framework dependencies
- Boot-time trust chain handled end-to-end (microcode → bootloader → initramfs → modules → firmware → session)

## Stack

| Role | Tool |
|---|---|
| Compositor | Hyprland (uwsm session) |
| Bar | waybar |
| Notifications | swaync |
| Launcher | rofi-wayland |
| Wallpaper | awww |
| Terminal | kitty |
| Shell | zsh + starship |
| Display manager | SDDM (greetd optional via flag) |

## Install options

```bash
./install.sh --help   # full flag reference
```

## Hardware support

- **CPUs:** Intel, AMD (microcode auto-selected)
- **GPUs:** NVIDIA (Turing+, Maxwell-Pascal, Fermi-Kepler legacy), AMD (RDNA + legacy GCN), Intel (Xe/Arc + legacy i965), Optimus hybrid
- **Bootloaders:** GRUB, systemd-boot, rEFInd (auto-detected)
- **WiFi:** In-tree modules preferred; Realtek DKMS via `--force-rtl-dkms`

## Themes

Currently ships **Tokyo Night** only. Theme architecture under `source/themes/` supports adding more (cyberpunk, catppuccin) in v1.3+.

## Keybindings

See [docs/keybindings.md](docs/keybindings.md).

## Post-install

- Multi-monitor: run `nwg-displays` to generate your `hypr/monitors.conf`
- Machine-specific env: edit `~/.config/zsh/user.local.zsh` (gitignored)

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).

## Roadmap

| Milestone | Scope | Status |
|---|---|---|
| M0 | Repo scaffolding, CI green on empty repo | ⏳ in progress |
| M1 | Configs migration + net-new configs | ⬜ pending |
| M2 | Installer skeleton (preflight, detect, `--dry-run`) | ⬜ pending |
| M3 | Core phases (packages, audio, fonts, symlinks, theme, services) | ⬜ pending |
| M4 | Hardware paths (GPU/WiFi/bootloader/DM) + v1.0 release | ⬜ pending |

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

## Security

See [docs/SECURITY.md](docs/SECURITY.md).

## License

MIT — see [LICENSE](LICENSE).
