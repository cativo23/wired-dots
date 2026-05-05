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

**A cyberpunk Hyprland setup for Arch Linux — palette-driven theming, NERV-grade desktop.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-5046e4?style=flat)](https://hyprland.org/)
[![Status](https://img.shields.io/badge/status-M0_scaffolding-orange?style=flat)](docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md)

> **Status:** v0.1.0-m0 — repo scaffolding only. Installer and runtime CLI ship in M2/M3.

</div>

---

## What is this?

wired-dots is a **palette-driven, runtime-themable Hyprland desktop** for Arch Linux. Inspired by Symphony's switching model and built around the [nightwire](https://github.com/cativo23/nightwire) design system.

See the full design contract: [docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md](docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md).

## Roadmap

| Milestone | Status | Scope |
|---|---|---|
| **M0 — Scaffolding** | 🚧 In progress | Repo skeleton, CI green on empty scaffold |
| **M1 — Configs** | ⏳ Pending | Migrate Hyprland/waybar/kitty/etc configs + initial 2 themes |
| **M2 — Installer** | ⏳ Pending | TUI installer with `gum`, hardware detect, dry-run |
| **M3 — Core phases** | ⏳ Pending | Packages, audio, fonts, symlinks, theme, services, bootloader |
| **v1.0.0** | ⏳ Pending | Stable release after 30-day daily-driver dogfooding |

## Quick install (M2+)

```bash
# Coming when installer ships in M2
git clone https://github.com/cativo23/wired-dots.git ~/wired-dots
cd ~/wired-dots
./install.sh
```

## Themes shipped at v1.0.0

- **nightwire** — Pure void with soft neon. Sibling of the [nightwire design system](https://github.com/cativo23/nightwire).
- **nervwire** — NERV-coded, naranja agresivo + verde tóxico.

`bladerunner` and `monochrome` land in v1.1.0. Wallpaper-driven `chaos` mode lands in v1.2.0.

## Hardware support

See [SUPPORT.md](SUPPORT.md) for the full tiered matrix. **TL;DR**: modern UEFI hardware (NVIDIA Turing+, AMD RDNA+, Intel Xe+).

## License

MIT — see [LICENSE](LICENSE).
