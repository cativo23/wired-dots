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
    kitty
    starship
    fastfetch
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
# zsh/ and waybar/ are intentionally NOT here — they use file-level layouts
# (per-file symlinks, deploy-time files) handled by deploy_zsh() and
# deploy_waybar() respectively.

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

deploy_zsh() {
    # zsh/ uses a hybrid layout to keep user edits across re-runs:
    #   - .zshrc, wired-defaults.zsh  → symlinks (always wired-managed)
    #   - user.zsh, user.local.zsh    → copied ONCE from .example templates,
    #                                   never overwritten if already present
    local src="$REPO_ROOT/zsh"
    local dst="$HOME/.config/zsh"
    if [[ ! -d "$src" ]]; then
        log_skip "zsh/ source dir not found"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy zsh/ via hybrid layout to $dst"
        return 0
    fi

    # Migration: previous wired-dots versions whole-dir-symlinked ~/.config/zsh
    # to repo/zsh/. Drop that symlink so we can rebuild as a real directory
    # with file-level symlinks. The repo previously also shipped user.zsh as
    # a tracked file; that content is now identical to user.zsh.example so
    # nothing of value is lost when the symlink is replaced.
    if [[ -L "$dst" ]]; then
        log_warn "migrating zsh/ from whole-dir symlink to hybrid layout"
        rm -f "$dst"
    fi

    mkdir -p "$dst"

    # Wired-managed files — symlink (refresh on every install)
    local f
    for f in .zshrc wired-defaults.zsh; do
        if [[ -f "$src/$f" ]]; then
            symlink_safe "$src/$f" "$dst/$f"
        fi
    done

    # User-owned templates — copy ONCE then leave alone
    local tmpl target
    for tmpl in user.zsh.example user.local.zsh.example; do
        target="${tmpl%.example}"
        if [[ ! -f "$src/$tmpl" ]]; then
            continue
        fi
        if [[ -e "$dst/$target" ]]; then
            log_skip "preserving existing $dst/$target"
        else
            cp "$src/$tmpl" "$dst/$target"
            log_ok "seeded $dst/$target from template (edit freely; future installs won't overwrite)"
        fi
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

deploy_waybar() {
    # File-level layout for ~/.config/waybar/. Replaces the old whole-dir
    # symlink + cp-into-source-dir pattern, which dirtied the repo on every
    # install (gitignored, but still ugly) and meant `~/.config/waybar/X`
    # writes always backflowed into the repo.
    #
    #   ~/.config/waybar/                  real directory
    #     ├── modules/   → repo/waybar/modules/   (subdir symlink)
    #     ├── includes/  → repo/waybar/includes/
    #     ├── layouts/   → repo/waybar/layouts/
    #     ├── styles/    → repo/waybar/styles/
    #     ├── menus/     → repo/waybar/menus/      (if present)
    #     ├── config.jsonc   → repo/waybar/layouts/cyberdeck-nerv.jsonc
    #     ├── style.css      → repo/waybar/styles/cyberdeck-nerv.css
    #     └── defaults.css   → repo/waybar/styles/defaults.css
    local src="$REPO_ROOT/waybar"
    local dst="$HOME/.config/waybar"
    if [[ ! -d "$src" ]]; then
        log_skip "waybar/ source dir not found"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy waybar/ via per-file symlinks to $dst"
        return 0
    fi

    # Migration: pre-PR-G installs whole-dir-symlinked ~/.config/waybar to
    # repo/waybar/, AND wrote generated config.jsonc/style.css/defaults.css
    # into the source dir. Drop the symlink and the orphan generated files
    # so the new layout owns the deploy target cleanly.
    if [[ -L "$dst" ]]; then
        log_warn "migrating waybar/ from whole-dir symlink to file-level layout"
        rm -f "$dst"
    fi
    local orphan
    for orphan in "$src/config.jsonc" "$src/style.css" "$src/defaults.css"; do
        [[ -f "$orphan" && ! -L "$orphan" ]] && rm -f "$orphan"
    done

    mkdir -p "$dst"

    # Subdirs that ship in the repo: link as a unit so module/style edits in
    # the repo land in ~/.config/waybar/ without re-running the installer.
    local sub
    for sub in modules includes layouts styles menus; do
        if [[ -d "$src/$sub" ]]; then
            symlink_safe "$src/$sub" "$dst/$sub"
        fi
    done

    # Active layout + style + defaults: file-level symlinks pointing at the
    # canonical sources under styles/ and layouts/. Switching the active
    # layout becomes `ln -sfn layouts/<other>.jsonc config.jsonc`.
    if [[ -f "$src/layouts/cyberdeck-nerv.jsonc" ]]; then
        symlink_safe "$src/layouts/cyberdeck-nerv.jsonc" "$dst/config.jsonc"
    fi
    if [[ -f "$src/styles/cyberdeck-nerv.css" ]]; then
        symlink_safe "$src/styles/cyberdeck-nerv.css" "$dst/style.css"
    fi
    if [[ -f "$src/styles/defaults.css" ]]; then
        # Also at the deploy root so style.css's `@import "defaults.css"` works
        # whether GTK CSS resolves relative to the symlink or its target.
        symlink_safe "$src/styles/defaults.css" "$dst/defaults.css"
    fi
    log_ok "waybar deployed (cyberdeck-nerv layout active)"
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
    deploy_zsh
    deploy_waybar
    link_home_dotfiles
    link_bin_files
    link_system_assets
    deploy_wallpapers
    rebuild_bat_cache
    log_ok "symlinks complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
