#!/usr/bin/env bash
# wired-dots — phase 08: SDDM display manager + Silent SDDM theme
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# shellcheck disable=SC2034  # passed to install_packages by nameref
SDDM_PACKAGES=( sddm )
# shellcheck disable=SC2034  # AUR — passed to install_packages by nameref
SDDM_AUR_PACKAGES=( sddm-silent-theme )
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF_FILE="$SDDM_CONF_DIR/wired.conf"
SDDM_THEME="silent"

SDDM_CONF_CONTENT="[General]
Numlock=on

[Theme]
Current=${SDDM_THEME}

[Wayland]
SessionDir=/usr/share/wayland-sessions

[X11]
SessionDir=/usr/share/xsessions"

install_silent_theme() {
    # Skip if already present (handles re-run)
    if [[ -d "/usr/share/sddm/themes/${SDDM_THEME}" ]]; then
        log_skip "Silent SDDM theme already installed"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would install sddm-silent-theme via AUR"
        return 0
    fi
    if [[ -z "${AUR_HELPER:-}" ]]; then
        detect_aur_helper
    fi
    install_packages SDDM_AUR_PACKAGES "${AUR_HELPER:-yay}" "-S" "--needed" "--noconfirm"
}

write_sddm_conf() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would write $SDDM_CONF_FILE with Numlock=on + Theme=$SDDM_THEME + session dirs"
        return 0
    fi
    sudo mkdir -p "$SDDM_CONF_DIR"
    printf '%s\n' "$SDDM_CONF_CONTENT" | sudo tee "$SDDM_CONF_FILE" > /dev/null
    log_ok "SDDM config written → $SDDM_CONF_FILE (Theme=$SDDM_THEME)"
}

main() {
    log_step "08" "display manager (sddm)"
    install_packages SDDM_PACKAGES "sudo" "pacman" "-S" "--needed" "--noconfirm"
    install_silent_theme
    write_sddm_conf
    log_ok "SDDM setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
