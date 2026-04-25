#!/usr/bin/env bash
# wired-dots — phase 04d: Intel GPU packages
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

main() {
    log_step "04d" "GPU Intel (${GPU_TYPE:-intel-xe-arc})"

    local pkgs_raw=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        pkgs_raw+=("${line%% *}")
    done < "$REPO_ROOT/source/packages/gpu-intel.lst"

    install_packages pkgs_raw "sudo" "pacman" "-S" "--needed" "--noconfirm"
    log_ok "Intel GPU setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
