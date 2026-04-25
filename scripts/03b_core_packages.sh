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

main() {
    log_step "03b" "core packages"
    local pkgs_raw=()
    while IFS= read -r pkg; do
        pkgs_raw+=("$pkg")
    done < <(read_pkg_list "$REPO_ROOT/source/packages/core.lst")

    install_packages pkgs_raw "sudo" "pacman" "-S" "--needed" "--noconfirm"
    log_ok "core packages complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
