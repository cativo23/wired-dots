#!/usr/bin/env bash
# wired-dots — phase 09: bootloader configuration
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

GRUB_DEFAULT_FILE="${GRUB_DEFAULT_FILE:-/etc/default/grub}"

patch_grub_cmdline() {
    local cmdline="${GPU_CMDLINE:-}"

    if [[ -z "$cmdline" ]]; then
        log_skip "GPU_CMDLINE is empty — no GRUB patching needed"
        return 0
    fi

    if [[ ! -f "$GRUB_DEFAULT_FILE" ]]; then
        log_skip "$GRUB_DEFAULT_FILE not found — not a GRUB system"
        return 0
    fi

    local first_param
    first_param="${cmdline%% *}"
    if grep -qF "$first_param" "$GRUB_DEFAULT_FILE"; then
        log_skip "GRUB cmdline already contains '$first_param' — skipping"
        return 0
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would append '$cmdline' to GRUB_CMDLINE_LINUX_DEFAULT in $GRUB_DEFAULT_FILE"
        return 0
    fi

    sudo sed -i \
        "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 ${cmdline}\"|" \
        "$GRUB_DEFAULT_FILE"
    log_ok "appended '$cmdline' to GRUB_CMDLINE_LINUX_DEFAULT"

    if command -v grub-mkconfig &>/dev/null; then
        log_info "running grub-mkconfig..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg && log_ok "GRUB config regenerated" || log_warn "grub-mkconfig failed — run manually"
    else
        log_warn "grub-mkconfig not found — regenerate GRUB manually"
    fi
}

handle_systemd_boot() {
    log_info "systemd-boot detected."
    if [[ -n "${GPU_CMDLINE:-}" ]]; then
        log_warn "GPU_CMDLINE='${GPU_CMDLINE}' — add this to your entry's options line in /boot/loader/entries/*.conf"
    fi
    log_skip "systemd-boot: no automatic patching (edit entries manually)"
}

handle_refind() {
    log_info "rEFInd detected."
    if [[ -n "${GPU_CMDLINE:-}" ]]; then
        log_warn "GPU_CMDLINE='${GPU_CMDLINE}' — add this to 'options' in /boot/refind_linux.conf"
    fi
    log_skip "rEFInd: no automatic patching (edit refind_linux.conf manually)"
}

main() {
    log_step "09" "bootloader"

    local bl="${BOOTLOADER:-unknown}"
    case "$bl" in
        grub)          patch_grub_cmdline ;;
        systemd-boot)  handle_systemd_boot ;;
        refind)        handle_refind ;;
        unknown)
            log_warn "Bootloader unknown — skipping bootloader config"
            log_info "Re-run with GPU_CMDLINE set and BOOTLOADER=grub|systemd-boot|refind"
            ;;
        *)
            log_warn "Unrecognised bootloader '$bl' — skipping"
            ;;
    esac

    log_ok "bootloader phase complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
