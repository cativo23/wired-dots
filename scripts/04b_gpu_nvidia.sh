#!/usr/bin/env bash
# wired-dots — phase 04b: NVIDIA driver install + system config
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

MODPROBE_DIR="/etc/modprobe.d"
BLACKLIST_SRC="$REPO_ROOT/source/assets/modprobe/99-wired-nouveau-blacklist.conf"
I2C_SRC="$REPO_ROOT/source/assets/modprobe/99-wired-i2c-dev.conf"

install_nvidia_packages() {
    local pkg_list="${GPU_PKG_LIST:-gpu-nvidia-modern.lst}"
    local list_file="$REPO_ROOT/source/packages/$pkg_list"

    if [[ ! -f "$list_file" ]]; then
        log_err "GPU package list not found: $list_file"
        return 1
    fi

    local pkgs_raw=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        pkgs_raw+=("${line%% *}")
    done < "$list_file"

    if [[ ${#pkgs_raw[@]} -eq 0 ]]; then
        log_warn "No uncommented packages in $pkg_list — manual AUR install required for legacy NVIDIA"
        return 0
    fi

    install_packages pkgs_raw "sudo" "pacman" "-S" "--needed" "--noconfirm"
}

deploy_modprobe_configs() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would deploy nouveau blacklist + i2c-dev to $MODPROBE_DIR"
        return 0
    fi
    sudo mkdir -p "$MODPROBE_DIR"
    sudo cp "$BLACKLIST_SRC" "$MODPROBE_DIR/99-wired-nouveau-blacklist.conf"
    log_ok "deployed nouveau blacklist → $MODPROBE_DIR"
    sudo cp "$I2C_SRC" "$MODPROBE_DIR/99-wired-i2c-dev.conf"
    log_ok "deployed i2c-dev config → $MODPROBE_DIR"
}

patch_grub_nvidia_cmdline() {
    local grub_default="/etc/default/grub"
    local cmdline="${GPU_CMDLINE:-nvidia_drm.modeset=1 nvidia_drm.fbdev=1}"

    [[ -z "$cmdline" ]] && return 0
    [[ ! -f "$grub_default" ]] && { log_skip "no /etc/default/grub found (not GRUB bootloader)"; return 0; }

    if grep -qF "$cmdline" "$grub_default"; then
        log_skip "GRUB cmdline already contains NVIDIA params"
        return 0
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would append '$cmdline' to GRUB_CMDLINE_LINUX_DEFAULT in $grub_default"
        return 0
    fi

    sudo sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $cmdline\"|" "$grub_default"
    log_ok "NVIDIA kernel params added to $grub_default"
}

rebuild_initramfs() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would run mkinitcpio -P"
        return 0
    fi
    log_info "rebuilding initramfs (mkinitcpio -P)..."
    sudo mkinitcpio -P && log_ok "initramfs rebuilt" || log_warn "mkinitcpio -P failed — reboot may be needed"
}

main() {
    log_step "04b" "GPU NVIDIA (${GPU_TYPE:-nvidia-turing-plus})"
    install_nvidia_packages
    deploy_modprobe_configs
    patch_grub_nvidia_cmdline
    rebuild_initramfs
    log_ok "NVIDIA GPU setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
