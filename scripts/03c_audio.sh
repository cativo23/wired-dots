#!/usr/bin/env bash
# wired-dots — phase 03c: audio (pipewire stack)
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

AUDIO_PACKAGES=(
    pipewire
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    pavucontrol
    pamixer
)

enable_audio_services() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would enable pipewire.service + wireplumber.service (user)"
        return 0
    fi
    systemctl --user enable --now pipewire.service    2>/dev/null && log_ok "pipewire.service enabled"       || log_warn "pipewire.service enable failed (may need relogin)"
    systemctl --user enable --now wireplumber.service 2>/dev/null && log_ok "wireplumber.service enabled"    || log_warn "wireplumber.service enable failed"
    systemctl --user enable --now pipewire-pulse.service 2>/dev/null && log_ok "pipewire-pulse.service enabled" || log_warn "pipewire-pulse.service enable failed"
}

main() {
    log_step "03c" "audio (pipewire)"
    install_packages AUDIO_PACKAGES "sudo" "pacman" "-S" "--needed" "--noconfirm"
    enable_audio_services
    log_ok "audio complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
