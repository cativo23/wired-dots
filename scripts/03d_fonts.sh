#!/usr/bin/env bash
# wired-dots — phase 03d: fonts (AUR + pacman)
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

main() {
    log_step "03d" "fonts"

    if [[ -z "${AUR_HELPER:-}" ]]; then
        detect_aur_helper
    fi

    local pkgs_raw=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        pkgs_raw+=("${line%% *}")
    done < "$REPO_ROOT/source/packages/fonts.lst"

    install_packages pkgs_raw "${AUR_HELPER:-yay}" "-S" "--needed" "--noconfirm"

    if [[ "${DRY_RUN:-0}" != "1" ]]; then
        fc-cache -fv &>/dev/null && log_ok "font cache refreshed"
    else
        log_info "[dry-run] would run fc-cache -fv"
    fi

    log_ok "fonts complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
