#!/usr/bin/env bash
# wired-dots — phase 10a: enable system services
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

SYSTEM_SERVICES=(
    NetworkManager
    bluetooth
)

enable_system_services() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would enable: ${SYSTEM_SERVICES[*]}"
        return 0
    fi

    for svc in "${SYSTEM_SERVICES[@]}"; do
        if systemctl list-unit-files "${svc}.service" &>/dev/null; then
            sudo systemctl enable --now "${svc}.service" \
                && log_ok "${svc}.service enabled" \
                || log_warn "${svc}.service enable failed"
        else
            log_warn "${svc}.service not found — skipping (package may not be installed yet)"
        fi
    done
}

enable_display_manager() {
    local dm="${DISPLAY_MANAGER:-sddm}"

    if [[ "$dm" == "none" || "${NO_DISPLAY_MANAGER:-0}" == "1" ]]; then
        log_skip "display manager skipped"
        return 0
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would enable ${dm}.service"
        return 0
    fi

    if systemctl list-unit-files "${dm}.service" &>/dev/null; then
        sudo systemctl enable "${dm}.service" \
            && log_ok "${dm}.service enabled" \
            || log_warn "${dm}.service enable failed"
    else
        log_warn "${dm}.service not found — was the display manager installed?"
    fi
}

enable_seatd() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would enable seatd.service and add user to seat group"
        return 0
    fi

    if systemctl list-unit-files seatd.service &>/dev/null; then
        sudo systemctl enable --now seatd.service && log_ok "seatd.service enabled" || log_warn "seatd.service enable failed"
        sudo usermod -aG seat "$USER" 2>/dev/null && log_ok "user $USER added to seat group" || log_warn "could not add $USER to seat group"
    else
        log_skip "seatd.service not found — skipping (may not be needed)"
    fi
}

change_login_shell() {
    # Switch the user's login shell to zsh. Required for ~/.config/zsh/.zshrc
    # to be sourced (and therefore starship/aliases to load) at SDDM login.
    local user="${SUDO_USER:-${USER:-$(id -un)}}"
    local current_shell
    current_shell="$(getent passwd "$user" | cut -d: -f7)"

    if [[ "$current_shell" == "/usr/bin/zsh" || "$current_shell" == "/bin/zsh" ]]; then
        log_skip "login shell for $user is already zsh"
        return 0
    fi
    if ! command -v zsh &>/dev/null; then
        log_warn "zsh not installed — skipping shell change"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would chsh -s /usr/bin/zsh $user"
        return 0
    fi
    sudo chsh -s /usr/bin/zsh "$user" \
        && log_ok "login shell for $user changed to /usr/bin/zsh" \
        || log_warn "chsh failed for $user"
}

main() {
    log_step "10a" "system services"
    enable_system_services
    enable_display_manager
    enable_seatd
    change_login_shell
    log_ok "system services complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
