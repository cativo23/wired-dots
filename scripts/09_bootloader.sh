#!/usr/bin/env bash
# wired-dots — phase 09: bootloader configuration
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

GRUB_DEFAULT_FILE="${GRUB_DEFAULT_FILE:-/etc/default/grub}"
# Upstream switched to date-based tags after v2.4.0.
readonly ELEGANT_GRUB_TAG="2025-03-25"

patch_grub_cmdline() {
    local cmdline="${GPU_CMDLINE:-}"

    if [[ -z "$cmdline" ]]; then
        log_skip "GPU_CMDLINE is empty — no GRUB cmdline patching needed"
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
}

regenerate_grub_config() {
    if command -v grub-mkconfig &>/dev/null; then
        log_info "running grub-mkconfig..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg \
            && log_ok "GRUB config regenerated" \
            || log_warn "grub-mkconfig failed — run manually: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    else
        log_warn "grub-mkconfig not found — regenerate GRUB manually"
    fi
}

install_grub_elegant_theme() {
    local grub_theme_dir="/usr/share/grub/themes/Elegant-mojave-float-left-dark"

    if [[ -d "$grub_theme_dir" ]]; then
        log_skip "GRUB Elegant theme already installed (${grub_theme_dir})"
        return 0
    fi

    if ! command -v git &>/dev/null; then
        log_warn "git not found — cannot install GRUB Elegant theme; install git and re-run"
        return 0
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would clone Elegant-grub2-themes tag ${ELEGANT_GRUB_TAG} and install mojave-float-left-dark"
        log_info "[dry-run] would run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
        return 0
    fi

    local tmpdir
    tmpdir="$(mktemp -d)"
    # shellcheck disable=SC2064  # intentional: expand $tmpdir now, at trap definition
    trap "rm -rf '${tmpdir}'" RETURN

    if ! git clone --depth 1 --branch "$ELEGANT_GRUB_TAG" \
            https://github.com/vinceliuice/Elegant-grub2-themes.git \
            "${tmpdir}/Elegant-grub2-themes"; then
        log_warn "Could not clone Elegant-grub2-themes — check internet connection"
        return 0
    fi

    if [[ ! -f "${tmpdir}/Elegant-grub2-themes/install.sh" ]]; then
        log_err "Elegant-grub2-themes repo does not contain install.sh"
        return 1
    fi

    if (cd "${tmpdir}/Elegant-grub2-themes" && sudo bash install.sh -t mojave -p float -i left -c dark); then
        log_ok "GRUB Elegant theme installed (mojave-float-left-dark)"
    else
        log_err "Elegant install.sh failed — GRUB theme not installed"
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
        grub)
            patch_grub_cmdline
            install_grub_elegant_theme
            # Run mkconfig once to capture both the cmdline patch and the theme
            # written by the upstream install.sh, avoiding a double regenerate.
            if [[ "${DRY_RUN:-0}" != "1" ]]; then
                regenerate_grub_config
            fi
            ;;
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
