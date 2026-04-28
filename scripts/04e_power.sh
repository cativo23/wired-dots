#!/usr/bin/env bash
# wired-dots — phase 04e: power management
#
# When WITH_TLP=1: deploys the wired-dots TLP config and (only on hardware
# that supports it) writes a charge-threshold overlay. Both files live in
# /etc/tlp.d/ so they layer on top of TLP's defaults without overwriting
# the package's own /etc/tlp.conf.
#
# When WITH_TLP=0: no-op. Wired-dots ships power-profiles-daemon by
# default; PPD self-enables and needs no per-host config.
#
# Charge thresholds are vendor-specific (only ThinkPads, some Lenovos,
# a handful of Dells/HPs expose them via the standard sysfs interface).
# Writing the lines unconditionally on unsupported hardware is harmless
# but noisy in logs, so we gate on actual sysfs availability.
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

TLP_SRC="$REPO_ROOT/source/assets/tlp/tlp.d/99-wired.conf"
TLP_DST="/etc/tlp.d/99-wired.conf"
THRESH_DST="/etc/tlp.d/99-wired-charge-thresh.conf"

# Default thresholds — override by exporting WIRED_CHARGE_START / STOP before
# running the installer (or by editing the generated file post-install).
WIRED_CHARGE_START="${WIRED_CHARGE_START:-20}"
WIRED_CHARGE_STOP="${WIRED_CHARGE_STOP:-80}"

deploy_tlp_base() {
    if [[ ! -f "$TLP_SRC" ]]; then
        log_warn "TLP source not found at $TLP_SRC — skipping"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy $TLP_DST"
        return 0
    fi
    sudo install -Dm644 "$TLP_SRC" "$TLP_DST"
    log_ok "TLP base config deployed → $TLP_DST"
}

# Returns the first BAT? whose charge_control thresholds are writable, or
# empty string if none. Discovers any battery slot (BAT0/BAT1/BAT2…) which
# is more portable than hardcoding BAT0.
detect_charge_threshold_battery() {
    local bat
    for bat in /sys/class/power_supply/BAT*; do
        [[ -d "$bat" ]] || continue
        local start="$bat/charge_control_start_threshold"
        local stop="$bat/charge_control_end_threshold"
        if [[ -w "$start" && -w "$stop" ]]; then
            basename "$bat"
            return 0
        fi
    done
    return 1
}

deploy_charge_thresholds() {
    local bat
    if ! bat="$(detect_charge_threshold_battery)"; then
        log_skip "no battery exposes writable charge thresholds — skipping overlay"
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would write $THRESH_DST for $bat"
        return 0
    fi
    sudo tee "$THRESH_DST" >/dev/null <<EOF
# wired-dots — generated charge-threshold overlay
# Detected battery: ${bat}. Hardware-gated by phase 04e_power.sh.
# Edit and re-run install (or just systemctl restart tlp) to apply.

START_CHARGE_THRESH_${bat}=${WIRED_CHARGE_START}
STOP_CHARGE_THRESH_${bat}=${WIRED_CHARGE_STOP}
EOF
    sudo chmod 0644 "$THRESH_DST"
    log_ok "charge thresholds (${WIRED_CHARGE_START}/${WIRED_CHARGE_STOP}%) → $THRESH_DST"
}

main() {
    log_step "04e" "power management"
    if [[ "${WITH_TLP:-0}" != "1" ]]; then
        log_skip "TLP not requested (--with-tlp); using power-profiles-daemon defaults"
        return 0
    fi
    deploy_tlp_base
    deploy_charge_thresholds
    log_ok "power management configured"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
