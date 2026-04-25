#!/usr/bin/env bash
# wired-dots — phase 08: greetd display manager (alternative to SDDM)
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

GREETD_PACKAGES=( greetd greetd-tuigreet )
GREETD_CONF_DIR="/etc/greetd"
GREETD_CONF_FILE="$GREETD_CONF_DIR/config.toml"

GREETD_CONF_CONTENT='[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --cmd \"uwsm start hyprland-uwsm.desktop\""
user = "greeter"'

write_greetd_conf() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would write $GREETD_CONF_FILE (tuigreet + uwsm → hyprland)"
        return 0
    fi
    sudo mkdir -p "$GREETD_CONF_DIR"
    printf '%s\n' "$GREETD_CONF_CONTENT" | sudo tee "$GREETD_CONF_FILE" > /dev/null
    log_ok "greetd config written → $GREETD_CONF_FILE"
}

enable_greetd() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would enable greetd.service"
        return 0
    fi
    sudo systemctl enable greetd.service && log_ok "greetd.service enabled" || log_warn "greetd.service enable failed"
}

main() {
    log_step "08" "display manager (greetd)"
    install_packages GREETD_PACKAGES "sudo" "pacman" "-S" "--needed" "--noconfirm"
    write_greetd_conf
    enable_greetd
    log_ok "greetd setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
