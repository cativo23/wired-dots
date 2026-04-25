#!/usr/bin/env bash
# wired-dots — phase 04c: AMD GPU packages
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

main() {
    log_step "04c" "GPU AMD (${GPU_TYPE:-amd-rdna})"

    local pkgs_raw=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        pkgs_raw+=("${line%% *}")
    done < "$REPO_ROOT/source/packages/gpu-amd.lst"

    install_packages pkgs_raw "sudo" "pacman" "-S" "--needed" "--noconfirm"
    log_ok "AMD GPU setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
