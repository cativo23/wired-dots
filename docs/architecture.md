# Architecture

> **Status:** Stub — fleshed out in M2/M3 as components land.

This document is the operational companion to the design spec.
For the full design contract see
[docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md](superpowers/specs/2026-05-04-wired-dots-v2-design.md).

## Three layers

1. **Installer** (`installer/`) — runs once at install time. Hardware
   detection, package install, system theme deploy.
2. **CLI runtime** (`cli/`, `bin/wired`) — runtime theme switching,
   wallpaper cycling, vibe/focus toggle.
3. **Theme system** (`themes/`, `templates/`, `hooks/`) — palette-driven
   generation: `palette.toml` + `envsubst` templates → outputs.

## Data flow on `wired switch <name>`

```text
parse themes/<name>/palette.toml
  → envsubst < templates/*.tmpl > ~/.config/wired/cache/themes/<name>/*
  → cp themes/<name>/overrides/* (if any) over cache
  → ln -sfn cache/themes/<name> ~/.config/wired/current
  → write state.toml
  → run hooks/NN-*.sh in order
  → notify via swaync
```

## State directory

```text
~/.config/wired/
├── current → cache/themes/<active>/
├── state.toml
└── cache/themes/<name>/
    ├── kitty.conf
    ├── waybar.css
    └── ...
```

App configs reference the symlink (e.g. kitty
`include ~/.config/wired/current/kitty.conf`).
Switching = atomic symlink update + hook reload.

## Further reading

- [adding-a-theme.md](adding-a-theme.md) — contributor guide for new themes
- [keybindings.md](keybindings.md) — Hyprland binds shipped with wired-dots
- [troubleshooting.md](troubleshooting.md) — common problems and fixes
- [release-procedure.md](release-procedure.md) — how releases are cut
