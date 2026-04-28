#!/usr/bin/env bash
# wired-dots — installer orchestrator
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

# ── Defaults ──────────────────────────────────────────────────────────────────
export DRY_RUN=0
export NONINTERACTIVE=0
export NO_PACKAGES=0
export NO_GPU=0
export NO_WIFI=0
export NO_BOOTLOADER=0
export NO_DISPLAY_MANAGER=0
export NO_SERVICES=0
export DISPLAY_MANAGER="sddm"
export GPU_OVERRIDE=""
export AUR_HELPER_OVERRIDE=""
export FORCE_RTL_DKMS=0
export WITH_KDE_APPS=0
export WITH_TLP=0
export WITH_NOISE_SUPPRESSION=0
export STRICT=0
export OPTIMIZE_MIRRORS=0
export ON_CONFLICT="overwrite"
export PREFIX=""

# ── User choices (flags + interactive prompts) ───────────────────────────────
# Empty defaults so we can detect "not set" vs "explicitly chosen via flag".
# interactive_prompts() fills missing values; final fallbacks land in
# 02b_user_choices.sh.
export KB_LAYOUT=""
export WIRED_BROWSER=""
export WIRED_FILE_MANAGER=""

# Choice catalogs — used both for validation and for the interactive menu.
KB_LAYOUT_OPTIONS=( "us" "latam,us" "es" "fr" "de" "br" "gb" )
BROWSER_OPTIONS=(   "brave-bin" "firefox" "chromium" )
FM_OPTIONS=(        "dolphin" "nautilus" "thunar" "nemo" "pcmanfm-gtk3" )

# ── Flag parsing ──────────────────────────────────────────────────────────────
_validate_choice() {
    # _validate_choice <flag-name> <value> <option1> <option2> ...
    local flag="$1" value="$2"; shift 2
    local opt
    for opt in "$@"; do
        [[ "$opt" == "$value" ]] && return 0
    done
    log_err "Unknown $flag value: $value. Allowed: $*"
    exit 1
}

parse_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)               DRY_RUN=1 ;;
            --strict)                STRICT=1 ;;
            --no-packages)           NO_PACKAGES=1 ;;
            --no-gpu)                NO_GPU=1 ;;
            --no-wifi)               NO_WIFI=1 ;;
            --no-bootloader)         NO_BOOTLOADER=1 ;;
            --no-display-manager)    NO_DISPLAY_MANAGER=1; DISPLAY_MANAGER="none" ;;
            --no-services)           NO_SERVICES=1 ;;
            --force-rtl-dkms)        FORCE_RTL_DKMS=1 ;;
            --with-kde-apps)         WITH_KDE_APPS=1 ;;
            --with-tlp)              WITH_TLP=1 ;;
            --with-noise-suppression) WITH_NOISE_SUPPRESSION=1 ;;
            --optimize-mirrors)      OPTIMIZE_MIRRORS=1 ;;
            --display-manager=sddm|--display-manager=greetd|--display-manager=none)
                DISPLAY_MANAGER="${1#--display-manager=}" ;;
            --display-manager=*)
                log_err "Unknown display manager: ${1#--display-manager=}. Use sddm|greetd|none"
                exit 1 ;;
            --gpu=nvidia|--gpu=amd|--gpu=intel|--gpu=hybrid)
                GPU_OVERRIDE="${1#--gpu=}" ;;
            --gpu=*)
                log_err "Unknown GPU override: ${1#--gpu=}. Use nvidia|amd|intel|hybrid"
                exit 1 ;;
            --aur-helper=paru|--aur-helper=yay)
                AUR_HELPER_OVERRIDE="${1#--aur-helper=}"
                AUR_HELPER="$AUR_HELPER_OVERRIDE"
                export AUR_HELPER ;;
            --aur-helper=*)
                log_err "Unknown AUR helper: ${1#--aur-helper=}. Use paru|yay"
                exit 1 ;;
            --on-conflict=overwrite|--on-conflict=skip|--on-conflict=abort)
                ON_CONFLICT="${1#--on-conflict=}" ;;
            --on-conflict=*)
                log_err "Unknown conflict strategy: ${1#--on-conflict=}. Use overwrite|skip|abort"
                exit 1 ;;
            --kb-layout=*)
                KB_LAYOUT="${1#--kb-layout=}"
                _validate_choice "--kb-layout" "$KB_LAYOUT" "${KB_LAYOUT_OPTIONS[@]}"
                ;;
            --with-browser=*)
                WIRED_BROWSER="${1#--with-browser=}"
                _validate_choice "--with-browser" "$WIRED_BROWSER" "${BROWSER_OPTIONS[@]}"
                ;;
            --with-file-manager=*)
                WIRED_FILE_MANAGER="${1#--with-file-manager=}"
                _validate_choice "--with-file-manager" "$WIRED_FILE_MANAGER" "${FM_OPTIONS[@]}"
                ;;
            --noninteractive)        NONINTERACTIVE=1 ;;
            --prefix=*)
                PREFIX="${1#--prefix=}"
                NO_PACKAGES=1; NO_GPU=1; NO_WIFI=1
                NO_BOOTLOADER=1; NO_DISPLAY_MANAGER=1; NO_SERVICES=1 ;;
            --help|-h) print_help; exit 0 ;;
            --version|-v) print_version; exit 0 ;;
            *)
                log_err "Unknown flag: $1. Run $0 --help for usage."
                exit 1 ;;
        esac
        shift
    done
}

print_help() {
    local version
    version="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || printf 'dev')"
    cat <<EOF
wired-dots $version
A cyberpunk Hyprland setup for Arch — Tokyo Night aesthetic.

USAGE
  ./install.sh [FLAGS]

CORE
  --dry-run                Simulate; no changes applied.
  --strict                 Abort on SecureBoot-enabled or unsupported initramfs.
  --prefix=<path>          Rebase full \$HOME to <path>; implies all --no-* hw flags.
  --help                   Print this help.
  --version                Print VERSION file contents.

HARDWARE
  --gpu=nvidia|amd|intel|hybrid     Override GPU detection.
  --no-gpu                          Skip GPU driver install.
  --no-wifi                         Skip WiFi driver install.
  --force-rtl-dkms                  Use DKMS module instead of in-tree rtw88.
  --no-bootloader                   Skip bootloader patching + theme.

COMPONENTS
  --no-packages                     Skip pacman/AUR install.
  --aur-helper=paru|yay             Override AUR helper detection.
  --display-manager=sddm|greetd|none  (default: sddm)
  --no-display-manager              Equivalent to --display-manager=none
  --with-kde-apps                   Include ark, ffmpegthumbs.
  --with-tlp                        Use TLP instead of PPD (laptop only).
  --with-noise-suppression          Enable WirePlumber RNNoise profile.
  --on-conflict=overwrite|skip|abort  Symlink conflict default (CI: abort).

USER CHOICES (interactive prompt if omitted in a tty)
  --kb-layout=us|latam,us|es|fr|de|br|gb   Hyprland kb_layout (default: us)
  --with-browser=brave-bin|firefox|chromium    Default: brave-bin
  --with-file-manager=dolphin|nautilus|thunar|nemo|pcmanfm-gtk3
                                                Default: dolphin
  --noninteractive                  Skip prompts; use defaults / flag values.

TESTING
  --optimize-mirrors                Reflector-based mirror sort.
  --no-services                     Skip systemctl enable/restart.

NOTES:
  Legacy NVIDIA (Maxwell, Pascal, Fermi, Kepler) requires manual AUR install.
  The installer will detect these GPUs and warn, but will not install drivers
  automatically. See docs/NVIDIA-LEGACY.md for manual steps.

See README.md for full documentation.
EOF
}

print_version() {
    cat "$REPO_ROOT/VERSION" 2>/dev/null || printf '%s\n' "${WIRED_DOTS_VERSION:-unknown}"
}

# ── User choice prompts (interactive only) ───────────────────────────────────
# Defaults applied here when neither flag nor prompt set a value, so tests and
# --noninteractive runs are deterministic.
KB_LAYOUT_DEFAULT="us"
BROWSER_DEFAULT="brave-bin"
FM_DEFAULT="dolphin"

_prompt_choice() {
    # _prompt_choice <label> <default> <options-array-name>
    # Reads user pick from stdin; falls back to default on empty/EOF.
    local label="$1" default="$2" arr_name="$3"
    local -n options="$arr_name"
    local opt i=1 default_idx=1
    echo "" >&2
    echo "  ${label}:" >&2
    for opt in "${options[@]}"; do
        if [[ "$opt" == "$default" ]]; then
            printf '    %d) %s  (default)\n' "$i" "$opt" >&2
            default_idx="$i"
        else
            printf '    %d) %s\n' "$i" "$opt" >&2
        fi
        ((i++))
    done
    local pick=""
    read -r -p "  pick [${default_idx}]: " pick </dev/tty 2>/dev/null || pick=""
    if [[ -z "$pick" ]]; then
        printf '%s' "$default"
        return
    fi
    if ! [[ "$pick" =~ ^[0-9]+$ ]] || (( pick < 1 || pick > ${#options[@]} )); then
        log_warn "  invalid pick '$pick', using default ($default)" >&2
        printf '%s' "$default"
        return
    fi
    printf '%s' "${options[pick-1]}"
}

interactive_prompts() {
    # Skip prompts if non-interactive, dry-run, or stdin isn't a tty. Empty
    # values then fall through to defaults in apply_user_choice_defaults().
    if [[ "${NONINTERACTIVE:-0}" == "1" ]] || [[ "${DRY_RUN:-0}" == "1" ]]; then
        return 0
    fi
    if [[ ! -t 0 ]] && [[ ! -r /dev/tty ]]; then
        return 0
    fi

    echo ""
    log_info "wired-dots — quick choices (Enter to accept defaults)"
    [[ -z "$KB_LAYOUT" ]]         && KB_LAYOUT="$(_prompt_choice         "Keyboard layout" "$KB_LAYOUT_DEFAULT" KB_LAYOUT_OPTIONS)"
    [[ -z "$WIRED_BROWSER" ]]     && WIRED_BROWSER="$(_prompt_choice     "Browser"         "$BROWSER_DEFAULT"  BROWSER_OPTIONS)"
    [[ -z "$WIRED_FILE_MANAGER" ]]&& WIRED_FILE_MANAGER="$(_prompt_choice "File manager"   "$FM_DEFAULT"       FM_OPTIONS)"
    echo ""
}

apply_user_choice_defaults() {
    : "${KB_LAYOUT:=$KB_LAYOUT_DEFAULT}"
    : "${WIRED_BROWSER:=$BROWSER_DEFAULT}"
    : "${WIRED_FILE_MANAGER:=$FM_DEFAULT}"
    log_info "user choices: kb_layout=$KB_LAYOUT  browser=$WIRED_BROWSER  file-manager=$WIRED_FILE_MANAGER"
}

# ── Log directory setup ───────────────────────────────────────────────────────
setup_log_dir() {
    local log_base="$HOME/.cache/wired-dots/logs/$WIRED_LOG"
    mkdir -p "$log_base"
    export WIRED_LOG_DIR="$log_base"
}

# ── Phase runner ──────────────────────────────────────────────────────────────
run_phase() {
    local script="$SCRIPTS_DIR/$1"
    local phase_name="$2"
    local start_ts
    start_ts="$(date +%s)"

    if [[ ! -x "$script" ]]; then
        log_err "Phase script not found or not executable: $script"
        exit 2
    fi

    export WIRED_LOG_FILE="$WIRED_LOG_DIR/${1%.sh}.log"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] phase: $phase_name"
        return 0
    fi

    "$script"
    local end_ts elapsed
    end_ts="$(date +%s)"
    elapsed=$(( end_ts - start_ts ))
    local mins=$(( elapsed / 60 )) secs=$(( elapsed % 60 ))
    printf -v elapsed_fmt '%dm %02ds' "$mins" "$secs"
    log_ok "phase $phase_name complete (${elapsed_fmt})"
}

run_phases() {
    setup_log_dir

    [[ "${DRY_RUN:-0}" == "1" ]] && log_info "[dry-run] simulating all phases — no changes will be made"

    run_phase "00_preflight.sh"   "00 · preflight"
    run_phase "01_backup.sh"      "01 · backup"
    run_phase "02_detect.sh"      "02 · detect"

    # Re-run detection in orchestrator scope so detected values propagate to
    # subsequent phase routing (run_phase forks a subprocess; child exports are lost).
    detect_cpu        >/dev/null 2>&1 || true
    detect_gpu        >/dev/null 2>&1 || true
    detect_wifi       >/dev/null 2>&1 || true
    detect_battery    >/dev/null 2>&1 || true
    detect_bootloader >/dev/null 2>&1 || true
    detect_kernels    >/dev/null 2>&1 || true
    [[ -z "${AUR_HELPER:-}" ]] && detect_aur_helper >/dev/null 2>&1 || true

    run_phase "02b_user_choices.sh" "02b · user choices"

    if [[ "$NO_PACKAGES" != "1" ]]; then
        run_phase "03a_pacman_tweaks.sh" "03a · pacman tweaks"
        run_phase "03b_core_packages.sh" "03b · core packages"
        run_phase "03c_audio.sh"         "03c · audio"
        run_phase "03d_fonts.sh"         "03d · fonts"
        run_phase "03e_bluetooth.sh"     "03e · bluetooth"
        run_phase "03f_aur_packages.sh"  "03f · AUR packages"
    else
        log_skip "packages skipped (--no-packages)"
    fi

    if [[ "$NO_GPU" != "1" ]]; then
        run_phase "04a_gpu_detect.sh" "04a · GPU detect"
        # Propagate override / re-detect for routing (subprocess exports are lost)
        if [[ -n "${GPU_OVERRIDE:-}" ]]; then
            GPU_TYPE="${GPU_TYPE:-$GPU_OVERRIDE}"
        elif [[ -z "${GPU_TYPE:-}" ]]; then
            detect_gpu >/dev/null 2>&1 || true
        fi
        case "${GPU_TYPE:-unknown}" in
            nvidia*) run_phase "04b_gpu_nvidia.sh" "04b · GPU NVIDIA" ;;
            amd*)    run_phase "04c_gpu_amd.sh"    "04c · GPU AMD" ;;
            intel*)  run_phase "04d_gpu_intel.sh"  "04d · GPU Intel" ;;
            hybrid*) run_phase "04b_gpu_nvidia.sh" "04b · GPU NVIDIA (hybrid)"
                     run_phase "04c_gpu_amd.sh"    "04c · GPU AMD (hybrid)" ;;
            unknown) log_warn "GPU unknown — skipping GPU driver install. Use --gpu= to override." ;;
        esac
    else
        log_skip "GPU install skipped (--no-gpu)"
    fi

    [[ "$NO_WIFI" != "1" ]] && run_phase "05_wifi.sh" "05 · WiFi" || log_skip "WiFi skipped"

    run_phase "06_symlinks.sh" "06 · symlinks"
    run_phase "07_theme.sh"    "07 · theme"

    if [[ "$NO_DISPLAY_MANAGER" != "1" && "$DISPLAY_MANAGER" != "none" ]]; then
        run_phase "08_${DISPLAY_MANAGER}.sh" "08 · display manager ($DISPLAY_MANAGER)"
    else
        log_skip "display manager skipped"
    fi

    [[ "$NO_BOOTLOADER" != "1" ]] && run_phase "09_bootloader.sh" "09 · bootloader" || log_skip "bootloader skipped"

    if [[ "$NO_SERVICES" != "1" ]]; then
        run_phase "10a_system_services.sh"    "10a · services"
        run_phase "10b_xdg_portal_restart.sh" "10b · XDG portals"
    else
        log_skip "services skipped"
    fi

    run_phase "10c_verification.sh" "10c · verification"
}

main() {
    parse_flags "$@"
    interactive_prompts
    apply_user_choice_defaults
    export DRY_RUN NONINTERACTIVE NO_PACKAGES NO_GPU NO_WIFI NO_BOOTLOADER
    export NO_DISPLAY_MANAGER NO_SERVICES DISPLAY_MANAGER GPU_OVERRIDE
    export FORCE_RTL_DKMS WITH_KDE_APPS WITH_TLP WITH_NOISE_SUPPRESSION
    export STRICT OPTIMIZE_MIRRORS ON_CONFLICT PREFIX
    export KB_LAYOUT WIRED_BROWSER WIRED_FILE_MANAGER
    run_phases
}

main "$@"
