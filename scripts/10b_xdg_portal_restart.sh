#!/usr/bin/env bash
# wired-dots — phase 10b: restart XDG desktop portals
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

PORTAL_PROCESSES=(
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-desktop-portal
)

restart_xdg_portals() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would kill and restart: ${PORTAL_PROCESSES[*]}"
        return 0
    fi

    for proc in "${PORTAL_PROCESSES[@]}"; do
        if pkill -x "$proc" 2>/dev/null; then
            log_ok "killed: $proc"
        else
            log_skip "$proc not running"
        fi
    done

    sleep 1

    for proc in "${PORTAL_PROCESSES[@]}"; do
        local unit="${proc}.service"
        if systemctl --user list-unit-files "$unit" &>/dev/null 2>&1; then
            systemctl --user restart "$unit" 2>/dev/null \
                && log_ok "restarted user unit: $unit" \
                || log_warn "could not restart $unit (will auto-start on next app launch)"
        fi
    done
}

main() {
    log_step "10b" "XDG portal restart"
    restart_xdg_portals
    log_ok "XDG portals restarted"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
