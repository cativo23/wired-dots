#!/usr/bin/env bash
# wired-dots — phase 03f: AUR packages
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

main() {
    log_step "03f" "AUR packages"

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
    done < "$REPO_ROOT/source/packages/aur.lst"

    # User-choice browser when it's NOT in the pacman repos (e.g. brave-bin).
    # Repo-resident choices (firefox, chromium) were already installed by 03b.
    if [[ -n "${WIRED_BROWSER:-}" ]] && ! pacman -Si "$WIRED_BROWSER" >/dev/null 2>&1; then
        pkgs_raw+=("$WIRED_BROWSER")
    fi
    # Same for file manager — most are repo, but if a future option is AUR-only
    # this catches it without code change.
    if [[ -n "${WIRED_FILE_MANAGER:-}" ]] && ! pacman -Si "$WIRED_FILE_MANAGER" >/dev/null 2>&1; then
        pkgs_raw+=("$WIRED_FILE_MANAGER")
    fi

    install_packages pkgs_raw "${AUR_HELPER:-yay}" "-S" "--needed" "--noconfirm"
    log_ok "AUR packages complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
