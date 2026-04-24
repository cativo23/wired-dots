# Security Policy

## Supported Versions

Only the latest tagged release is supported for security fixes.

## Reporting a Vulnerability

Open a private security advisory via GitHub: https://github.com/cativo23/wired-dots/security/advisories/new

For non-sensitive bugs, use regular issues.

## What this repo does NOT contain

- API keys, tokens, passwords, or credentials
- Private or public SSH keys
- `.env` files

Machine-specific secrets belong in `~/.config/zsh/user.local.zsh` (gitignored).

## Clipboard history security

The installer enables `cliphist` watchers for text AND image clipboards by default. This means **passwords, OTP codes, and API tokens copied to the clipboard are persisted** to `~/.cache/cliphist/db` in plaintext.

Mitigations applied by installer:
- `chmod 700` on `~/.cache/cliphist/`
- `chmod 600` on the db file

Manual actions if you want stricter posture:
- Wipe history: `cliphist wipe`
- Disable image clipboard: remove the `wl-paste --type image --watch cliphist store` exec-once line from `hypr/userprefs.conf`
- Disable all clipboard history: remove both cliphist watchers from `hypr/userprefs.conf`

Future (v1.2+): opt-in deny-list for password-manager windows (bitwarden, keepassxc) via Hyprland window rules.

## SecureBoot + DKMS signing

Arch DKMS modules (nvidia-dkms, rtl8821ce-dkms-git) are unsigned and will be rejected on boot if SecureBoot is enabled.

Options:
1. **Disable SecureBoot** in firmware setup (simplest)
2. **Sign with sbctl**: https://github.com/Foxboron/sbctl — setup outside this installer's scope
3. **Skip DKMS paths**: run `./install.sh --no-gpu --force-rtl-dkms=no` and rely on in-tree modules

The installer's preflight will warn when SecureBoot is detected enabled. Use `--strict` to abort entirely.
