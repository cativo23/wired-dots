#!/usr/bin/env bash
# wired-dots — phase 03a: pacman.conf tweaks + hooks
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

PACMAN_CONF="/etc/pacman.conf"

PACMAN_PATCH="# --- wired-dots tweaks (do not edit below this line) ---
Color
ILoveCandy
ParallelDownloads = 5
# --- end wired-dots tweaks ---"

patch_pacman_conf() {
    local state=0
    # Capture exit code safely under set -e: sentinel_check returns 1 or 2 on non-applied states
    sentinel_check "$PACMAN_CONF" && state=0 || state=$?
    # Insert under [options] (not at end-of-file, which would land in the last [repo] section)
    case $state in
        0) log_skip "pacman.conf already patched (sentinel ok)" ;;
        1) log_warn "pacman.conf changed since last apply — re-patching"
           apply_patch "$PACMAN_CONF" "$PACMAN_PATCH" '^\[options\]' ;;
        2) apply_patch "$PACMAN_CONF" "$PACMAN_PATCH" '^\[options\]' ;;
    esac
}

install_pacman_hooks() {
    local hooks_dir="/etc/pacman.d/hooks"
    local hook_src="$REPO_ROOT/source/assets/pacman-hooks/nvidia.hook"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would create $hooks_dir and install hooks"
        return 0
    fi

    sudo mkdir -p "$hooks_dir"

    if [[ "${GPU_TYPE:-unknown}" == nvidia* || "${GPU_TYPE:-unknown}" == hybrid* ]]; then
        if [[ ! -f "$hook_src" ]]; then
            log_warn "nvidia.hook not found at $hook_src — skipping"
            return 0
        fi
        sudo cp "$hook_src" "$hooks_dir/nvidia.hook"
        log_ok "installed nvidia pacman hook → $hooks_dir/nvidia.hook"
    else
        log_skip "nvidia hook not needed (GPU_TYPE=${GPU_TYPE:-unknown})"
    fi
}

main() {
    log_step "03a" "pacman tweaks"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would patch $PACMAN_CONF and install pacman hooks"
        log_ok "pacman tweaks complete (dry-run)"
        return 0
    fi

    patch_pacman_conf
    install_pacman_hooks
    log_ok "pacman tweaks complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
