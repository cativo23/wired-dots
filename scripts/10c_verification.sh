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

VERIFY_SYMLINKS=(
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/kitty"
    "$HOME/.config/zsh"
    "$HOME/.zshenv"
)

check_package() {
    pkg_installed "$1"
}

check_symlink() {
    local path="$1"
    [[ -L "$path" && -e "$path" ]]
}

run_checks() {
    local pkg_ok=0 pkg_fail=0 sym_ok=0 sym_fail=0

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

    log_info "checking symlinks..."
    for sym in "${VERIFY_SYMLINKS[@]}"; do
        if check_symlink "$sym"; then
            log_ok "symlink valid: $sym"
            (( sym_ok++ )) || true
        else
            log_warn "symlink MISSING or broken: $sym"
            (( sym_fail++ )) || true
        fi
    done

    printf '\n'
    draw_box "10c · verification" \
"packages:   ${pkg_ok} ok  ${pkg_fail} missing
symlinks:   ${sym_ok} ok  ${sym_fail} missing
version:    ${WIRED_DOTS_VERSION:-unknown}
log:        ${WIRED_LOG:-unknown}" ""
    printf '\n'

    if [[ $pkg_fail -gt 0 || $sym_fail -gt 0 ]]; then
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
