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
    # Copy wallpapers from source/wallpapers/ (which contains the curated
    # submodule pack/ and may host repo-local extras) into ~/.config/wired-dots/
    # wallpapers/, then point ~/.config/wired-dots/current at the first one
    # alphabetically. Hyprland exec-once does `wallpaper set <current>` so
    # the choice persists across reboots without re-applying defaults.
    local dst="$HOME/.config/wired-dots/wallpapers"
    local current="$HOME/.config/wired-dots/current"
    local src="$REPO_ROOT/source/wallpapers"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy wallpapers to $dst and set current symlink"
        return 0
    fi
    mkdir -p "$dst"

    # Walk source/wallpapers/ recursively (submodule contents live under
    # pack/<theme>/) and collect every image. nullglob via subshell isolates
    # the shopt change from the parent script.
    local -a files
    mapfile -t files < <(
        find "$src" \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
            -type f 2>/dev/null | sort
    )

    if (( ${#files[@]} > 0 )); then
        # Flatten into $dst — basename collisions are rare in curated packs;
        # cp -n preserves the first one if a dup name appears.
        local f
        for f in "${files[@]}"; do
            cp -n "$f" "$dst/"
        done
        log_ok "deployed ${#files[@]} wallpaper(s) → $dst"
    elif command -v magick &>/dev/null; then
        log_warn "no wallpapers found under $src — submodule not cloned? generating fallback"
        log_info "    (run: git submodule update --init --recursive)"
        magick -size 1920x1080 'gradient:#1a1b26-#16161e' \
            "$dst/tokyo-night-default.png" 2>/dev/null \
            && log_ok "generated fallback gradient → $dst/tokyo-night-default.png"
    else
        log_skip "no wallpapers shipped + magick unavailable — wallpaper dir left empty"
        return 0
    fi

    # Point current symlink at the first wallpaper alphabetically (idempotent —
    # leave existing valid symlink alone so user's selection survives re-runs).
    if [[ -L "$current" ]] && [[ -e "$current" ]]; then
        log_skip "wallpaper current symlink already valid → $current"
    else
        local first
        first=$(find "$dst" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
            2>/dev/null | sort | head -n 1)
        if [[ -n "$first" ]]; then
            ln -sfn "$first" "$current"
            log_ok "current → $(basename "$first")"
        fi
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
