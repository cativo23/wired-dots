#!/usr/bin/env bash
# wired-dots — phase 08: SDDM display manager + Silent SDDM theme
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# shellcheck disable=SC2034  # passed to install_packages by nameref
SDDM_PACKAGES=( sddm qt5-virtualkeyboard )
# shellcheck disable=SC2034  # AUR — passed to install_packages by nameref
SDDM_AUR_PACKAGES=( sddm-silent-theme )
SDDM_CONF_DIR="/etc/sddm.conf.d"
# 00- prefix wins alphabetical merge against any pre-existing theme.conf
# from other installers that drop their own files in /etc/sddm.conf.d/.
SDDM_CONF_FILE="$SDDM_CONF_DIR/00-wired.conf"
SDDM_THEME="silent"
SDDM_VARIANT="rei"
SDDM_THEME_DIR="/usr/share/sddm/themes/${SDDM_THEME}"

SDDM_CONF_CONTENT="[General]
Numlock=on
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell,QT_QPA_PLATFORMTHEME=qt5ct

[Theme]
Current=${SDDM_THEME}

[Wayland]
SessionDir=/usr/share/wayland-sessions

[X11]
SessionDir=/usr/share/xsessions"

install_silent_theme() {
    if [[ -d "$SDDM_THEME_DIR" ]]; then
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
        log_info "[dry-run] would write $SDDM_CONF_FILE (Theme=$SDDM_THEME, InputMethod=qtvirtualkeyboard)"
        return 0
    fi
    sudo mkdir -p "$SDDM_CONF_DIR"
    # Remove any prior wired.conf written before the 00- prefix change.
    sudo rm -f "$SDDM_CONF_DIR/wired.conf"
    printf '%s\n' "$SDDM_CONF_CONTENT" | sudo tee "$SDDM_CONF_FILE" > /dev/null
    log_ok "SDDM config written → $SDDM_CONF_FILE (Theme=$SDDM_THEME)"
}

select_silent_variant() {
    # Silent SDDM theme reads /etc/sddm/themes/silent/conf.d/*.conf overrides;
    # writing the variant there keeps the change out of the package's own files.
    if [[ ! -d "$SDDM_THEME_DIR" ]]; then
        log_skip "$SDDM_THEME_DIR not present, skipping variant selection"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would set Silent variant=${SDDM_VARIANT}"
        return 0
    fi
    local override_dir="/etc/sddm/themes/${SDDM_THEME}/conf.d"
    sudo mkdir -p "$override_dir"
    printf '[General]\nvariant=%s\n' "$SDDM_VARIANT" \
        | sudo tee "$override_dir/00-wired-variant.conf" > /dev/null
    log_ok "Silent SDDM variant set: ${SDDM_VARIANT}"
}

main() {
    log_step "08" "display manager (sddm)"
    install_packages SDDM_PACKAGES "sudo" "pacman" "-S" "--needed" "--noconfirm"
    install_silent_theme
    write_sddm_conf
    select_silent_variant
    log_ok "SDDM setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
