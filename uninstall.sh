#!/usr/bin/env bash
# wired-dots — uninstall (M0 minimum viable)
#
# Per spec (docs/superpowers/specs/2026-04-24-wired-dots-design.md line 361):
#   - Removes repo symlinks from ~/.config/* and ~/.local/bin/*
#   - Restores latest ~/.local/share/wired-dots/backups/<TS>/ via cp -a
#   - Prints list of /etc/*.wired.bkp sentinels with revert instructions
#   - Does NOT touch packages, services, bootloader, or display manager
# Exit 0 on success.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# Mirrors 06_symlinks.sh CONFIG_DIRS + 01_backup.sh BACKUP_CONFIG_DIRS.
CONFIG_DIRS=(
    hypr waybar kitty starship fastfetch zsh swaync rofi wlogout
    bat gtk-3.0 gtk-4.0 qt5ct qt6ct Kvantum xdg-desktop-portal
    wireplumber git
)
HOME_DOTFILES=( .zshenv .gtkrc-2.0 )
BIN_FILES=( cliphist-rofi power-profile-switch screenshot.sh wallpaper )

# Direct-deploy /etc files (no .wired.bkp sentinel — installer cp's them).
# Listed for the user to sudo rm manually. Format: "path|description".
ETC_ARTIFACTS=(
    "/etc/sddm.conf.d/wired.conf|SDDM theme config (08_sddm.sh)"
    "/etc/sddm.conf.d/00-wired.conf|SDDM theme config — newer prefix (08_sddm.sh)"
    "/etc/NetworkManager/conf.d/99-wired.conf|NM DNS settings (06_symlinks.sh)"
    "/etc/udev/rules.d/90-brightness.rules|udev brightness rules (06_symlinks.sh)"
)

remove_symlinks_from() {
    local label="$1" base="$2"; shift 2
    local removed=0
    for name in "$@"; do
        local target="$base/$name"
        if [[ -L "$target" ]]; then
            if [[ "${DRY_RUN:-0}" == "1" ]]; then
                log_info "[dry-run] would unlink: $target"
            else
                rm -f "$target"
                log_ok "removed symlink: $target"
            fi
            (( removed++ )) || true
        fi
    done
    log_info "$label: removed $removed symlink(s)"
}

remove_runtime_artifacts() {
    # Files/dirs the installer creates that aren't symlinks: deployed
    # wallpapers + the legacy ~/.local/share/waybar/styles dir from pre-rc2.
    local items=( "$HOME/.config/wired-dots" "$HOME/.local/share/waybar" )
    for item in "${items[@]}"; do
        [[ -e "$item" ]] || continue
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            log_info "[dry-run] would remove: $item"
        else
            rm -rf "$item"
            log_ok "removed: $item"
        fi
    done
}

restore_latest_backup() {
    local backups_root="$HOME/.local/share/wired-dots/backups"
    if [[ ! -d "$backups_root" ]]; then
        log_skip "no wired-dots backups found"
        return 0
    fi
    local latest
    latest=$(find "$backups_root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r | head -n 1)
    if [[ -z "$latest" ]]; then
        log_skip "backup root exists but is empty: $backups_root"
        return 0
    fi
    log_info "restoring from: $latest"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would cp -a contents of $latest into ~/.config/ and ~/"
        return 0
    fi

    local restored=0
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -e "$latest/$dir" ]]; then
            cp -a "$latest/$dir" "$HOME/.config/$dir"
            log_ok "restored: ~/.config/$dir"
            (( restored++ )) || true
        fi
    done
    for f in "${HOME_DOTFILES[@]}"; do
        if [[ -e "$latest/$f" ]]; then
            cp -a "$latest/$f" "$HOME/$f"
            log_ok "restored: ~/$f"
            (( restored++ )) || true
        fi
    done
    log_ok "restored $restored item(s) from $latest"
}

print_manual_revert_instructions() {
    echo
    log_warn "uninstall does NOT touch packages, services, bootloader, or DM"
    echo

    # /etc/*.wired.bkp sentinels (apply_patch creates these — see global_fn.sh).
    local sentinels=()
    while IFS= read -r -d '' f; do
        sentinels+=( "$f" )
    done < <(find /etc -maxdepth 4 -name '*.wired.bkp' -print0 2>/dev/null)

    if (( ${#sentinels[@]} > 0 )); then
        echo "Patched system files (sentinels found):"
        for s in "${sentinels[@]}"; do
            echo "  $s"
            echo "    original at: ${s%.wired.bkp}  — revert manually"
        done
        echo
    fi

    # Direct-deploy /etc files.
    local present=()
    for entry in "${ETC_ARTIFACTS[@]}"; do
        local path="${entry%%|*}"
        local desc="${entry#*|}"
        [[ -e "$path" ]] && present+=( "$path  # $desc" )
    done
    if (( ${#present[@]} > 0 )); then
        echo "wired-dots /etc artifacts (sudo rm to revert):"
        printf '  %s\n' "${present[@]}"
        echo
    fi

    cat <<'EOF'
Other manual reverts (out of scope per spec):
  Bootloader  : sudo rm -rf /boot/grub/themes/Elegant-* && sudo grub-mkconfig -o /boot/grub/grub.cfg
  DM theme    : sudo pacman -Rns sddm-theme-silent  (if installed and unwanted)
  Packages    : see source/packages/{core,aur}.lst — sudo pacman -Rns <pkg>
EOF
}

main() {
    log_step "uninstall" "wired-dots M0 minimum viable"
    remove_symlinks_from "configs"       "$HOME/.config"    "${CONFIG_DIRS[@]}"
    remove_symlinks_from "home dotfiles" "$HOME"            "${HOME_DOTFILES[@]}"
    remove_symlinks_from "bin"           "$HOME/.local/bin" "${BIN_FILES[@]}"
    remove_runtime_artifacts
    restore_latest_backup
    print_manual_revert_instructions
    log_ok "uninstall complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi
