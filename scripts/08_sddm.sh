#!/usr/bin/env bash
# wired-dots — phase 08: SDDM display manager
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# shellcheck disable=SC2034  # passed to install_packages by nameref
SDDM_PACKAGES=( sddm )
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF_FILE="$SDDM_CONF_DIR/wired.conf"

SDDM_CONF_CONTENT="[General]
Numlock=on

[Wayland]
SessionDir=/usr/share/wayland-sessions

[X11]
SessionDir=/usr/share/xsessions"

write_sddm_conf() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would write $SDDM_CONF_FILE with Numlock=on + session dirs"
        return 0
    fi
    sudo mkdir -p "$SDDM_CONF_DIR"
    printf '%s\n' "$SDDM_CONF_CONTENT" | sudo tee "$SDDM_CONF_FILE" > /dev/null
    log_ok "SDDM config written → $SDDM_CONF_FILE"
}

main() {
    log_step "08" "display manager (sddm)"
    install_packages SDDM_PACKAGES "sudo" "pacman" "-S" "--needed" "--noconfirm"
    write_sddm_conf
    log_ok "SDDM setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
