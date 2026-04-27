#!/usr/bin/env bash
# wired-dots — phase 06: deploy configs via symlinks
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

CONFIG_DIRS=(
    hypr
    waybar
    kitty
    starship
    fastfetch
    zsh
    swaync
    rofi
    wlogout
    bat
    gtk-3.0
    gtk-4.0
    qt5ct
    qt6ct
    Kvantum
    xdg-desktop-portal
    wireplumber
    git
)

link_config_dirs() {
    mkdir -p "$HOME/.config"
    for dir in "${CONFIG_DIRS[@]}"; do
        local src="$REPO_ROOT/$dir"
        local dst="$HOME/.config/$dir"
        if [[ ! -d "$src" ]]; then
            log_warn "source dir not found, skipping: $src"
            continue
        fi
        symlink_safe "$src" "$dst"
    done
}

link_home_dotfiles() {
    local home_src="$REPO_ROOT/home"
    if [[ ! -d "$home_src" ]]; then
        log_warn "home/ directory not found in repo — skipping home dotfiles"
        return 0
    fi

    local count=0
    while IFS= read -r -d '' file; do
        local rel="${file#"$home_src/"}"
        local dst="$HOME/$rel"
        symlink_safe "$file" "$dst"
        (( count++ )) || true
    done < <(find "$home_src" -maxdepth 1 -type f -print0 2>/dev/null)

    if [[ $count -eq 0 ]]; then
        log_skip "home/ directory is empty — no home dotfiles to link"
    fi
}

link_bin_files() {
    local bin_src="$REPO_ROOT/bin"
    if [[ ! -d "$bin_src" ]]; then
        log_warn "bin/ directory not found in repo — skipping bin symlinks"
        return 0
    fi
    mkdir -p "$HOME/.local/bin"
    while IFS= read -r -d '' file; do
        local filename
        filename="$(basename "$file")"
        local dst="$HOME/.local/bin/$filename"
        symlink_safe "$file" "$dst"
    done < <(find "$bin_src" -maxdepth 1 \( -type f -o -type l \) -print0)

    if ! printf '%s' "${PATH:-}" | grep -q "$HOME/.local/bin"; then
        log_warn "$HOME/.local/bin is not in PATH — add it to your shell config (handled by ~/.config/zsh/)"
    fi
}

link_system_assets() {
    local nm_src="$REPO_ROOT/source/assets/networkmanager/conf.d/99-wired.conf"
    local nm_dst="/etc/NetworkManager/conf.d/99-wired.conf"
    local udev_src="$REPO_ROOT/source/assets/udev/90-brightness.rules"
    local udev_dst="/etc/udev/rules.d/90-brightness.rules"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy: $nm_dst"
        log_info "[dry-run] would deploy: $udev_dst"
        return 0
    fi

    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo cp "$nm_src" "$nm_dst"
    log_ok "deployed NetworkManager config → $nm_dst"

    sudo mkdir -p /etc/udev/rules.d
    sudo cp "$udev_src" "$udev_dst"
    log_ok "deployed udev brightness rules → $udev_dst"

    sudo udevadm control --reload-rules 2>/dev/null && log_ok "udev rules reloaded" || log_warn "udev reload failed"
}

activate_waybar_layout() {
    # Per design spec: waybar/config.jsonc points at layouts/cyberdeck-nerv.jsonc
    # and waybar/style.css points at styles/cyberdeck-nerv.css. styles/defaults.css
    # is also materialized next to style.css so the @import resolves locally.
    local waybar_dir="$REPO_ROOT/waybar"
    local layout="$waybar_dir/layouts/cyberdeck-nerv.jsonc"
    local style="$waybar_dir/styles/cyberdeck-nerv.css"
    local defaults="$waybar_dir/styles/defaults.css"
    if [[ ! -f "$layout" ]] || [[ ! -f "$style" ]] || [[ ! -f "$defaults" ]]; then
        log_skip "waybar layout/style sources missing, skipping activation"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would activate waybar layout cyberdeck-nerv"
        return 0
    fi
    cp "$layout"   "$waybar_dir/config.jsonc"
    cp "$style"    "$waybar_dir/style.css"
    cp "$defaults" "$waybar_dir/defaults.css"
    log_ok "waybar layout activated (cyberdeck-nerv)"
}

rebuild_bat_cache() {
    # bat alias uses --theme=tokyonight_night; the theme file is symlinked but
    # bat needs `bat cache --build` to register it.
    if ! command -v bat &>/dev/null; then return 0; fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would run bat cache --build"
        return 0
    fi
    bat cache --build >/dev/null 2>&1 && log_ok "bat theme cache rebuilt"
}

deploy_wallpapers() {
    # Copy shipped wallpapers to ~/.config/wired-dots/wallpapers/. The default
    # is applied at session start by Hyprland exec-once (`wallpaper set …`),
    # not here — awww-daemon needs $WAYLAND_DISPLAY which doesn't exist yet.
    local dst="$HOME/.config/wired-dots/wallpapers"
    local src="$REPO_ROOT/source/wallpapers"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy wallpapers to $dst"
        return 0
    fi
    mkdir -p "$dst"

    # Collect shipped wallpapers via subshell with nullglob so unmatched globs
    # disappear (the previous compgen brace-expand only ever checked *.jpg).
    local -a files
    mapfile -t files < <(
        shopt -s nullglob
        printf '%s\n' "$src"/*.jpg "$src"/*.jpeg "$src"/*.png "$src"/*.webp
    )

    if (( ${#files[@]} > 0 )); then
        cp -n "${files[@]}" "$dst/"
        log_ok "deployed ${#files[@]} wallpaper(s) → $dst"
    elif command -v magick &>/dev/null && [[ -z "$(ls -A "$dst" 2>/dev/null)" ]]; then
        # imagemagick is in core.lst so this should work post-install
        magick -size 1920x1080 gradient:"#1a1b26"-"#16161e" \
            "$dst/tokyo-night-default.png" 2>/dev/null \
            && log_ok "generated default Tokyo Night wallpaper → $dst/tokyo-night-default.png"
    else
        log_skip "no wallpapers shipped + magick unavailable — wallpaper dir left empty"
    fi
}

main() {
    log_step "06" "symlinks"
    link_config_dirs
    activate_waybar_layout
    link_home_dotfiles
    link_bin_files
    link_system_assets
    deploy_wallpapers
    rebuild_bat_cache
    log_ok "symlinks complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
