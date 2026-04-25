#!/usr/bin/env bash
# wired-dots — phase 00: preflight checks
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        if grep -qi "arch" /etc/os-release 2>/dev/null; then
            log_warn "Non-standard Arch derivative detected — proceeding with caution"
            return 0
        fi
        log_err "wired-dots requires Arch Linux. Detected: $(. /etc/os-release && printf '%s' "$NAME" 2>/dev/null || printf 'unknown')"
        exit 2
    fi
    log_ok "Arch Linux confirmed"
}

check_internet() {
    if ping -c 1 -W 3 8.8.8.8 &>/dev/null || \
       ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
        log_ok "Internet connection confirmed"
        return 0
    fi
    log_err "No internet access. Check your connection and try again."
    exit 2
}

check_secureboot() {
    local sb_state
    sb_state="$(cat /sys/firmware/efi/efivars/SecureBoot-* 2>/dev/null | od -An -tu1 | awk '{print $NF}' || printf '0')"
    if [[ "$sb_state" == "1" ]]; then
        if [[ "${STRICT:-0}" == "1" ]]; then
            log_err "SecureBoot is enabled (--strict mode). Disable SecureBoot or use sbctl to sign modules."
            exit 2
        fi
        log_warn "SecureBoot is ENABLED — NVIDIA DKMS modules may fail to load."
        log_warn "  To fix: install sbctl and sign modules after install."
    else
        log_ok "SecureBoot disabled"
    fi
}

check_initramfs() {
    if command -v dracut &>/dev/null; then
        log_err "dracut detected. wired-dots v1.0 requires mkinitcpio."
        log_err "  Switch to mkinitcpio before running this installer."
        exit 2
    fi
    if command -v booster &>/dev/null; then
        log_err "booster detected. wired-dots v1.0 requires mkinitcpio."
        exit 2
    fi
    if command -v mkinitcpio &>/dev/null; then
        log_ok "mkinitcpio confirmed"
    else
        log_warn "mkinitcpio not found — will be installed via core packages"
    fi
}

check_sync_db() {
    if [[ ! -f /var/lib/pacman/sync/core.db ]]; then
        log_warn "pacman sync DB missing — running pacman -Sy"
        if [[ "${DRY_RUN:-0}" != "1" ]]; then
            sudo pacman -Sy --noconfirm || {
                log_err "Failed to sync pacman DB"
                exit 2
            }
        fi
    else
        log_ok "pacman sync DB present"
    fi
}

refresh_keyring() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would refresh archlinux-keyring"
        return 0
    fi
    log_step "00" "refreshing archlinux-keyring..."
    if ! sudo pacman -S --needed --noconfirm archlinux-keyring; then
        log_warn "keyring refresh failed — attempting manual recovery..."
        sudo pacman-key --init && \
        sudo pacman-key --populate archlinux && \
        sudo pacman-key --refresh-keys || {
            log_err "Keyring refresh failed. Pull archlinux-keyring manually:"
            log_err "  pacman -U https://archlinux.org/packages/core/x86_64/archlinux-keyring/"
            exit 2
        }
    fi
    log_ok "archlinux-keyring refreshed"
}

add_user_groups() {
    local groups=("video" "input" "seat" "i2c" "audio")
    local user="${SUDO_USER:-$USER}"
    for grp in "${groups[@]}"; do
        if getent group "$grp" &>/dev/null; then
            if [[ "${DRY_RUN:-0}" == "1" ]]; then
                log_info "[dry-run] would add $user to group $grp"
            else
                sudo usermod -aG "$grp" "$user" && log_ok "added $user → $grp" || log_warn "could not add $user → $grp"
            fi
        fi
    done
}

print_banner() {
    printf '\n%b' "$WIRED_COLOR_PURPLE"
    cat <<'BANNER'
    __      ___              __       __      __
    \ \    / (_)_ _ ___ _ __/ _|   __/ /_    / /____
     \ \/\/ /| | '_/ -_) -_) _/  / _  / /  / __(_-<
      \_/\_/ |_|_| \___\___|_|   \_,_/\__/  \__/___/
BANNER
    printf '%b\n' "$WIRED_COLOR_RESET"
    log_info "wired-dots v$(cat "$REPO_ROOT/VERSION" 2>/dev/null || printf 'dev')"
    log_info "Tokyo Night · Arch Linux · Hyprland"
    printf '\n'
}

main() {
    print_banner
    log_step "00" "preflight checks"

    check_arch_linux
    check_internet
    check_secureboot
    check_initramfs
    check_sync_db
    refresh_keyring
    detect_aur_helper
    detect_kernels
    detect_bootloader
    add_user_groups
    require_sudo

    if [[ "${OPTIMIZE_MIRRORS:-0}" == "1" ]]; then
        if command -v reflector &>/dev/null; then
            log_step "00" "optimizing mirrors (reflector)..."
            if [[ "${DRY_RUN:-0}" != "1" ]]; then
                local country
                country="$(curl -s ifconfig.co/country-iso 2>/dev/null || printf 'US')"
                sudo reflector --country "$country" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
            fi
            log_ok "mirrors optimized"
        else
            log_warn "reflector not installed — skipping mirror optimization"
        fi
    fi

    log_ok "preflight complete"
}

# Only run main when executed directly (not sourced for tests)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
