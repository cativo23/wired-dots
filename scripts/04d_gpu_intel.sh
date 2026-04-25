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

    case "${GPU_TYPE:-intel-xe-arc}" in
        intel-legacy-i965)
            # Pre-Gen 9 (Haswell and older): use legacy VA-API driver
            local pkgs=( vulkan-intel libva-intel-driver )
            install_packages pkgs "sudo" "pacman" "-S" "--needed" "--noconfirm"
            ;;
        *)
            # Gen 9+ (Broadwell, Skylake, Ice Lake, Xe, Arc): use modern driver
            local pkgs=( vulkan-intel intel-media-driver )
            install_packages pkgs "sudo" "pacman" "-S" "--needed" "--noconfirm"
            ;;
    esac

    log_ok "Intel GPU setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
