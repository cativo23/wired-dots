#!/usr/bin/env bash
# wired-dots — phase 03b: core pacman packages
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

read_pkg_list() {
    local file="$1"
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        printf '%s\n' "${line%% *}"
    done < "$file"
}

# Append a user-chosen package to the install list when it lives in the
# official pacman repos. AUR-only choices go to 03f.
append_user_choice_if_repo() {
    local -n out_arr="$1"
    local pkg="$2"
    [[ -z "$pkg" ]] && return 0
    if pacman -Si "$pkg" >/dev/null 2>&1; then
        out_arr+=("$pkg")
    fi
}

main() {
    log_step "03b" "core packages"
    local pkgs_raw=()
    while IFS= read -r pkg; do
        pkgs_raw+=("$pkg")
    done < <(read_pkg_list "$REPO_ROOT/source/packages/core.lst")

    # User choice: file manager + browser, when they're in the pacman repos
    # (everything except brave-bin). Skips silently in DRY_RUN since pacman -Si
    # may still work, or in --no-packages where this whole phase is skipped.
    append_user_choice_if_repo pkgs_raw "${WIRED_FILE_MANAGER:-}"
    append_user_choice_if_repo pkgs_raw "${WIRED_BROWSER:-}"

    # Power-management swap: with --with-tlp, replace power-profiles-daemon
    # with tlp + tlp-rdw. PPD and TLP both compete for cpufreq governor
    # control, so they must not be installed together.
    if [[ "${WITH_TLP:-0}" == "1" ]]; then
        local filtered=()
        local p
        for p in "${pkgs_raw[@]}"; do
            [[ "$p" == "power-profiles-daemon" ]] && continue
            filtered+=("$p")
        done
        pkgs_raw=( "${filtered[@]}" tlp tlp-rdw )
    fi

    install_packages pkgs_raw "sudo" "pacman" "-S" "--needed" "--noconfirm"
    log_ok "core packages complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
