#!/usr/bin/env bash
# wired-dots — phase 05: WiFi driver
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

RTL8821CE_MODULE="rtl8821ce"
RTL8821CE_AUR_PKG="rtl8821ce-dkms"

handle_wifi() {
    local module="${WIFI_MODULE:-none}"

    if [[ "$module" == "none" || -z "$module" ]]; then
        log_skip "no WiFi controller detected — skipping WiFi phase"
        return 0
    fi

    case "$module" in
        iwlwifi|mt7921*|rtw88*|rtw89*|ath10k*|ath11k*|ath12k*|brcmfmac|mwifiex)
            log_ok "WiFi module '$module' is in-tree — no DKMS package needed"
            ;;
        "$RTL8821CE_MODULE")
            if [[ "${FORCE_RTL_DKMS:-0}" == "1" ]]; then
                log_info "RTL8821CE detected with FORCE_RTL_DKMS=1 — installing $RTL8821CE_AUR_PKG"
                if [[ -z "${AUR_HELPER:-}" ]]; then
                    detect_aur_helper
                fi
                local pkgs=("$RTL8821CE_AUR_PKG")
                install_packages pkgs "${AUR_HELPER:-yay}" "-S" "--needed" "--noconfirm"
            else
                log_info "RTL8821CE detected. In-kernel rtw88 may work on recent kernels."
                log_info "If WiFi fails after install, re-run with FORCE_RTL_DKMS=1 or pass --force-rtl-dkms"
            fi
            ;;
        *)
            log_warn "Unknown WiFi module '$module' — no automatic action taken"
            log_info "You may need to install a kernel module manually for: $module"
            ;;
    esac
}

main() {
    log_step "05" "WiFi driver"
    handle_wifi
    log_ok "WiFi phase complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
