# Contributing to wired-dots

Thanks for considering a contribution.

## Scope

wired-dots is an opinionated Arch + Hyprland setup. Contributions most likely to land:

- Bug fixes on supported hardware (Intel/AMD/NVIDIA GPUs, common WiFi, UEFI with GRUB/systemd-boot/rEFInd)
- Additional rows in `source/detect/gpu-db.psv` for uncommon hardware
- Documentation improvements
- Additional themes under `source/themes/<name>/` that follow the existing structure

Less likely to land:

- Distro ports (non-Arch) — tracked as separate projects
- X11 support — Wayland-only by design
- Major compositor swaps (Sway, river) — out of scope

## Commit conventions

`:<gitmoji>: type(scope): description`

| Type | Gitmoji | Scope examples |
|---|---|---|
| feat | `:sparkles:` | installer, theme, waybar, new flag |
| fix | `:bug:` | phase, config, detection |
| docs | `:memo:` | readme, troubleshooting |
| refactor | `:recycle:` | phase split, helper extraction |
| chore | `:wrench:` | ci, deps, version bump |

## PR checklist

- [ ] `shellcheck --severity=warning scripts/*.sh install.sh uninstall.sh` is clean
- [ ] `./install.sh --dry-run` still works (once M2 lands)
- [ ] Packages added to `source/packages/*.lst` verified present in pacman or AUR
- [ ] CSS changes validated with `gtk4-builder-tool validate` where applicable
- [ ] New config files added to `verify_configs()` validation list
- [ ] README / troubleshooting / CHANGELOG updated where relevant

## Testing

See `docs/migration-from-hyde.md` for safe iteration via `--prefix=/tmp/wired-test`.
