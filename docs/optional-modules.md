# Optional Modules

Recipes for waybar/Hyprlock/etc. modules that are deliberately not shipped by default. Drop in if you want them.

## waybar — Claude Code status pill

A status pill that reports whether the [`claude` CLI](https://github.com/anthropics/claude-code) is installed and whether `ANTHROPIC_AUTH_TOKEN` (or `ANTHROPIC_API_KEY`) is set. Click opens a terminal in `claude`. Removed from the default ship in v1.0.0-rc3 because most users don't have/want it.

### 1. Drop the helper script

`~/.local/bin/waybar-claude-code`:

```bash
#!/usr/bin/env bash
# Reports a small status pill for the Claude Code CLI.
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
    printf '{"text":"","class":"missing","tooltip":"claude CLI not installed"}\n'
    exit 0
fi

if [[ -n "${ANTHROPIC_AUTH_TOKEN:-}${ANTHROPIC_API_KEY:-}" ]]; then
    printf '{"text":"","class":"ok","tooltip":"Claude Code ready"}\n'
else
    printf '{"text":"","class":"auth","tooltip":"set ANTHROPIC_AUTH_TOKEN in user.local.zsh"}\n'
fi
```

`chmod +x ~/.local/bin/waybar-claude-code`.

### 2. Drop the waybar module config

`~/.config/waybar/modules/custom-claude-code.jsonc`:

```jsonc
{
  "custom/claude-code": {
    "return-type": "json",
    "exec": "bash -c 'source ${NVM_DIR:-$HOME/.nvm}/nvm.sh 2>/dev/null; waybar-claude-code'",
    "format": "{text}",
    "interval": 300,
    "tooltip": true,
    "on-click": "${TERMINAL:-kitty} -e claude"
  }
}
```

### 3. Reference it from your active layout

Add `"custom/claude-code"` to whichever module group you want it in (e.g. `group/magi-panel`) in `~/.config/waybar/layouts/<your-layout>.jsonc`.

### 4. Reload waybar

```bash
killall waybar && waybar &
```

## Hyprlock — profile picture

The `silent-rei` layout ships with a commented-out `image { … }` block for a profile picture. To enable:

1. Save a square PNG (recommended ≥ 200×200) to `~/.config/hypr/hyprlock/profile.png`
2. Uncomment the block in `~/.config/hypr/hyprlock/silent-rei.conf`
3. Lock to test: `hyprlock`
