#!/usr/bin/env bash
# wired-dots — phase 03e: bluetooth
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# shellcheck disable=SC2034  # passed to install_packages by nameref
BT_PACKAGES=( bluez bluez-utils )
BT_ASSET="$REPO_ROOT/source/assets/bluez/main.conf.d/wired.conf"
BT_CONF_DIR="/etc/bluetooth/main.conf.d"

deploy_bluez_config() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy $BT_ASSET → $BT_CONF_DIR/wired.conf"
        return 0
    fi
    sudo mkdir -p "$BT_CONF_DIR"
    sudo cp "$BT_ASSET" "$BT_CONF_DIR/wired.conf"
    log_ok "deployed bluez wired.conf → $BT_CONF_DIR/wired.conf"
}

enable_bluetooth() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would enable bluetooth.service"
        return 0
    fi
    sudo systemctl enable --now bluetooth.service && log_ok "bluetooth.service enabled" || log_warn "bluetooth.service enable failed"
}

main() {
    log_step "03e" "bluetooth"
    install_packages BT_PACKAGES "sudo" "pacman" "-S" "--needed" "--noconfirm"
    deploy_bluez_config
    enable_bluetooth
    log_ok "bluetooth complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
