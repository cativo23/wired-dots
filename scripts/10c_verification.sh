#!/usr/bin/env bash
# wired-dots — phase 10c: post-install verification
# Non-fatal: logs warnings for missing items, never exits non-zero.
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

VERIFY_PACKAGES=(
    hyprland
    waybar
    pipewire
    wireplumber
    networkmanager
    bash
)
# Add display manager package only if one was selected
[[ "${DISPLAY_MANAGER:-sddm}" != "none" ]] && VERIFY_PACKAGES+=( "${DISPLAY_MANAGER:-sddm}" )

# Paths that must exist after install. Each entry is either a whole-dir
# symlink into the repo (legacy / single-file targets) OR a real directory
# that contains at least one managed file-level symlink (waybar, zsh).
# VERIFY_PATHS and VERIFY_SENTINELS are parallel arrays: a non-empty sentinel
# means "if the path is a real dir, assert this inner file is a valid symlink".
VERIFY_PATHS=(
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/kitty"
    "$HOME/.config/zsh"
    "$HOME/.zshenv"
)
VERIFY_SENTINELS=(
    ""
    "$HOME/.config/waybar/config.jsonc"
    ""
    "$HOME/.config/zsh/wired-defaults.zsh"
    ""
)

check_package() {
    pkg_installed "$1"
}

# Returns 0 if path is a valid whole-dir symlink OR (when a sentinel is given)
# a real directory containing that sentinel as a valid symlink.
check_managed_path() {
    local path="$1" sentinel="${2:-}"
    if [[ -L "$path" && -e "$path" ]]; then
        return 0
    fi
    if [[ -n "$sentinel" && -d "$path" && -L "$sentinel" && -e "$sentinel" ]]; then
        return 0
    fi
    return 1
}

run_checks() {
    local pkg_ok=0 pkg_fail=0 path_ok=0 path_fail=0

    log_info "checking packages..."
    for pkg in "${VERIFY_PACKAGES[@]}"; do
        if check_package "$pkg"; then
            log_ok "package installed: $pkg"
            (( pkg_ok++ )) || true
        else
            log_warn "package MISSING: $pkg"
            (( pkg_fail++ )) || true
        fi
    done

    log_info "checking managed paths..."
    local i
    for (( i = 0; i < ${#VERIFY_PATHS[@]}; i++ )); do
        local p="${VERIFY_PATHS[$i]}" s="${VERIFY_SENTINELS[$i]}"
        if check_managed_path "$p" "$s"; then
            log_ok "managed path OK: $p"
            (( path_ok++ )) || true
        else
            log_warn "managed path broken or missing: $p"
            (( path_fail++ )) || true
        fi
    done

    printf '\n'
    draw_box "10c · verification" \
"packages:   ${pkg_ok} ok  ${pkg_fail} missing
paths:      ${path_ok} ok  ${path_fail} broken
version:    ${WIRED_DOTS_VERSION:-unknown}
log:        ${WIRED_LOG:-unknown}" ""
    printf '\n'

    if [[ $pkg_fail -gt 0 || $path_fail -gt 0 ]]; then
        log_warn "verification found issues — see above. Re-run install or fix manually."
    else
        log_ok "all checks passed — wired-dots install looks healthy"
    fi
}

main() {
    log_step "10c" "verification"
    run_checks
    log_ok "verification complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
