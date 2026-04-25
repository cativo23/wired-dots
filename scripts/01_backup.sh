#!/usr/bin/env bash
# wired-dots — phase 01: backup existing configs
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# Config subdirs that 06_symlinks.sh will own — back these up first.
BACKUP_CONFIG_DIRS=(
    hypr waybar kitty starship fastfetch zsh swaync rofi wlogout
    bat gtk-3.0 gtk-4.0 qt5ct qt6ct Kvantum xdg-desktop-portal
    wireplumber git
)
# Home dotfiles that 06_symlinks.sh will own
BACKUP_DOTFILES=( .zshenv .gtkrc-2.0 )

backup_configs() {
    local wired_log="${WIRED_LOG:-$(date +%Y%m%dT%H%M%S)}"
    local backup_base="${HOME}/.local/share/wired-dots/backups/${wired_log}"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would backup configs to: $backup_base"
        return 0
    fi

    mkdir -p "$backup_base"
    local backed_up=0

    for dir in "${BACKUP_CONFIG_DIRS[@]}"; do
        local src="$HOME/.config/$dir"
        # Skip: does not exist, or is already a symlink (already managed)
        if [[ -e "$src" && ! -L "$src" ]]; then
            if cp -a "$src" "$backup_base/$dir" 2>/dev/null; then
                log_ok "backed up: $src"
                (( backed_up++ )) || true
            else
                log_warn "could not backup: $src"
            fi
        fi
    done

    for file in "${BACKUP_DOTFILES[@]}"; do
        local src="$HOME/$file"
        if [[ -e "$src" && ! -L "$src" ]]; then
            if cp -a "$src" "$backup_base/$file" 2>/dev/null; then
                log_ok "backed up: $src"
                (( backed_up++ )) || true
            else
                log_warn "could not backup: $src"
            fi
        fi
    done

    if [[ $backed_up -eq 0 ]]; then
        log_skip "nothing to backup (clean install or already symlinked)"
        rmdir "$backup_base" 2>/dev/null || true
    else
        log_ok "backup complete → $backup_base ($backed_up items)"
    fi
}

main() {
    log_step "01" "backup existing configs"
    backup_configs
    log_ok "backup phase complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
