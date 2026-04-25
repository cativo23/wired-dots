#!/usr/bin/env bash
# wired-dots — phase 02: hardware detection
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

print_detection_summary() {
    local battery_str bootloader_str bluetooth_str kernels_str
    [[ "${HAS_BATTERY:-0}" == "1" ]] && battery_str="yes" || battery_str="no (desktop)"
    [[ "${HAS_BLUETOOTH:-0}" == "1" ]] && bluetooth_str="yes" || bluetooth_str="no"
    bootloader_str="${BOOTLOADER:-unknown}"
    kernels_str="${KERNELS[*]:-unknown}"

    printf '\n'
    draw_box "02 · hardware detection" \
"CPU:        ${CPU_VENDOR:-unknown}
GPU:        ${GPU_TYPE:-unknown}
WiFi:       ${WIFI_MODULE:-none}
Battery:    $battery_str
Bluetooth:  $bluetooth_str
Bootloader: $bootloader_str
Kernels:    $kernels_str
AUR helper: ${AUR_HELPER:-none}" ""
    printf '\n'
}

detect_phase() {
    detect_cpu
    detect_gpu || {
        if [[ "${STRICT:-0}" == "1" ]]; then
            log_err "GPU unrecognized — pass --gpu=nvidia|amd|intel|hybrid to override"
            exit 3
        fi
        log_warn "GPU unrecognized — some GPU-specific steps may be skipped"
        GPU_TYPE="unknown"
        export GPU_TYPE
    }
    detect_wifi
    detect_battery || true
    detect_bluetooth || true
    detect_bootloader
    detect_kernels
    detect_aur_helper
}

main() {
    log_step "02" "hardware detection"
    detect_phase
    print_detection_summary
    log_ok "hardware detection complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
