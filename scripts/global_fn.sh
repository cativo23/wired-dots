#!/usr/bin/env bash
# wired-dots — shared installer helpers
# Sourced by install.sh and all phase scripts. Do NOT set -euo pipefail here.

# ── Tokyo Night palette (truecolor ANSI 24-bit) ──────────────────────────────
export WIRED_COLOR_BLUE='\033[38;2;122;162;247m'
export WIRED_COLOR_GREEN='\033[38;2;158;206;106m'
export WIRED_COLOR_YELLOW='\033[38;2;224;175;104m'
export WIRED_COLOR_RED='\033[38;2;247;118;142m'
export WIRED_COLOR_PURPLE='\033[38;2;187;154;247m'
export WIRED_COLOR_MUTED='\033[38;2;86;95;137m'
export WIRED_COLOR_RESET='\033[0m'

: "${REPO_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export REPO_ROOT

export WIRED_DOTS_VERSION
WIRED_DOTS_VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || printf 'unknown\n')"

# Per-run log directory identifier
: "${WIRED_LOG:=$(date +'%y%m%d_%Hh%Mm%Ss')}"
export WIRED_LOG

# print_log <color_var> <symbol> <message>
# Writes colored line to stdout + ANSI-stripped line to log file.
print_log() {
    local color="$1" symbol="$2" msg="$3"
    local log_file="${WIRED_LOG_FILE:-/dev/null}"
    local line
    printf -v line '%b%s %s%b\n' "$color" "$symbol" "$msg" "$WIRED_COLOR_RESET"
    printf '%b' "$line"
    # Write plain text (symbol + msg never contain ANSI codes)
    printf '%s\n' "$symbol $msg" >> "$log_file" 2>/dev/null || true
}

log_ok()   { print_log "$WIRED_COLOR_GREEN"  "✓" "$*"; }
log_warn() { print_log "$WIRED_COLOR_YELLOW" "⚠" "$*"; }
log_err()  { print_log "$WIRED_COLOR_RED"    "✗" "$*"; }
log_skip() { print_log "$WIRED_COLOR_MUTED"  "○" "$*"; }
log_info() { print_log "$WIRED_COLOR_BLUE"   "ℹ" "$*"; }
log_step() { print_log "$WIRED_COLOR_BLUE"   "▶" "$1 $2"; }

# draw_box <title> <content_lines> <duration>
# content_lines can be multi-line (use $'\n' separator).
# duration: "3m 14s" or "" to omit elapsed time footer.
draw_box() {
    local title="$1" content="$2" duration="${3:-}"
    local width=62
    local top_line
    printf -v top_line '╭─ phase %s ' "$title"
    local pad=$(( width - ${#top_line} - 1 ))
    [[ $pad -lt 2 ]] && pad=2
    printf '%b%s%*s╮%b\n' "$WIRED_COLOR_BLUE" "$top_line" "$(( pad + 2 ))" '─' "$WIRED_COLOR_RESET"
    while IFS= read -r line; do
        local inner_pad=$(( width - ${#line} - 4 ))
        [[ $inner_pad -lt 0 ]] && inner_pad=0
        printf '%b│%b  %s%*s%b│%b\n' \
            "$WIRED_COLOR_BLUE" "$WIRED_COLOR_RESET" \
            "$line" "$inner_pad" '' \
            "$WIRED_COLOR_BLUE" "$WIRED_COLOR_RESET"
    done <<< "$content"
    if [[ -n "$duration" ]]; then
        local dur_pad=$(( width - ${#duration} - 5 ))
        [[ $dur_pad -lt 2 ]] && dur_pad=2
        printf '%b╰%*s %s %b─╯%b\n' "$WIRED_COLOR_BLUE" "$(( dur_pad + 2 ))" '─' "$duration" "$WIRED_COLOR_MUTED" "$WIRED_COLOR_RESET"
    else
        printf '%b╰%*s╯%b\n' "$WIRED_COLOR_BLUE" "$(( width ))" '─' "$WIRED_COLOR_RESET"
    fi
}

# spinner <pid> <message>
# Shows braille animation until pid exits.
spinner() {
    local pid="$1" msg="$2"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r%b%s%b %s' "$WIRED_COLOR_BLUE" "${frames[$i]}" "$WIRED_COLOR_RESET" "$msg"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done
    printf '\r%*s\r' "$(( ${#msg} + 3 ))" ''
}

# prompt_timer <seconds> <message> <default>
# In NONINTERACTIVE=1 mode: immediately echoes default and returns.
# Interactive: shows countdown, returns user input or default on timeout.
prompt_timer() {
    local timeout="$1" msg="$2" default="$3"
    if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
        printf '%s\n' "$default"
        return 0
    fi
    local answer=""
    # Display goes to stderr so $() capture in confirm() only gets the answer
    printf '%b%s [%s] (auto in %ss): %b' \
        "$WIRED_COLOR_YELLOW" "$msg" "$default" "$timeout" "$WIRED_COLOR_RESET" >&2
    if read -rt "$timeout" -n 1 answer; then
        printf '\n' >&2
        answer="${answer:-$default}"
    else
        printf '\n' >&2
        answer="$default"
    fi
    printf '%s\n' "${answer,,}"
}

# confirm <prompt> <default_yn> <timeout>
# Returns 0 for yes, 1 for no.
confirm() {
    local prompt="$1" default="${2:-y}" timeout="${3:-10}"
    local answer
    answer="$(prompt_timer "$timeout" "$prompt" "$default")"
    [[ "${answer,,}" == "y"* ]]
}

# start_sudo_keepalive — refreshes sudo every 60s in background.
# Registers EXIT/INT/TERM/ERR trap to stop on exit.
start_sudo_keepalive() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then return 0; fi
    # Caller must authenticate before invoking. Keepalive refreshes in background.
    ( while true; do sudo -n true; sleep 60; done ) &
    SUDO_KEEPALIVE_PID=$!
    export SUDO_KEEPALIVE_PID
    # shellcheck disable=SC2064
    trap "stop_sudo_keepalive" EXIT INT TERM ERR
}

stop_sudo_keepalive() {
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
        unset SUDO_KEEPALIVE_PID
    fi
}

# require_sudo — validates sudo access, starts keepalive.
# Idempotent: no-op if keepalive already running.
require_sudo() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would require sudo"
        return 0
    fi
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then return 0; fi
    if ! sudo -v; then
        log_err "sudo authentication failed"
        exit 2
    fi
    start_sudo_keepalive
}

# pkg_installed <name> — returns 0 if package is installed locally.
pkg_installed() { pacman -Q "$1" &>/dev/null; }

# pkg_available <name> — returns 0 if in pacman sync DB.
pkg_available() { pacman -Si "$1" &>/dev/null; }

# aur_available <name> — returns 0 if in AUR (requires AUR helper).
aur_available() {
    local helper="${AUR_HELPER:-}"
    if [[ -z "$helper" ]]; then
        helper="$(command -v paru || command -v yay || true)"
    fi
    [[ -n "$helper" ]] || return 2
    "$helper" -Ss "^${1}$" &>/dev/null
}

# sentinel_check <file>
# Returns:
#   0 — patch already applied (hash matches .wired.bkp)
#   1 — file drifted since last apply
#   2 — never applied (no .wired.bkp)
sentinel_check() {
    local file="$1" sentinel="${1}.wired.bkp"
    [[ -f "$sentinel" ]] || return 2
    local current_hash saved_hash
    current_hash="$(sha256sum "$file" | awk '{print $1}')"
    saved_hash="$(cat "$sentinel")"
    [[ "$current_hash" == "$saved_hash" ]] && return 0
    return 1
}

# apply_patch <file> <patch_content>
# Appends patch_content to file, writes new sentinel hash.
# Backs up original to <file>.wired.orig if no backup exists.
apply_patch() {
    local file="$1" patch_content="$2"
    [[ -f "${file}.wired.orig" ]] || sudo cp "$file" "${file}.wired.orig"
    printf '%s\n' "$patch_content" | sudo tee -a "$file" > /dev/null
    sha256sum "$file" | awk '{print $1}' | sudo tee "${file}.wired.bkp" > /dev/null
    log_ok "patched $file"
}

# install_packages <array_name> <install_cmd...>
# Nameref: install_packages pkgs_array "pacman" "-S" "--needed" "--noconfirm"
# Each array entry: "pkg_name" or "pkg_name | dep | # comment" (only first field used).
install_packages() {
    local -n _pkgs="$1"
    shift
    local install_cmd=("$@")
    local queue=()
    for entry in "${_pkgs[@]}"; do
        local pkg
        pkg="$(printf '%s' "$entry" | cut -d'|' -f1 | tr -d ' ')"
        [[ -n "$pkg" && "$pkg" != "#"* ]] && queue+=("$pkg")
    done
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would install: ${queue[*]}"
        return 0
    fi
    if [[ ${#queue[@]} -gt 0 ]]; then
        "${install_cmd[@]}" "${queue[@]}"
    fi
}

# detect_gpu — matches lspci output against source/detect/gpu-db.psv
# Exports: GPU_TYPE (nvidia-turing-plus|amd-rdna|intel-xe-arc|...|unknown)
#          GPU_PKG_LIST (filename from packages/)
#          GPU_CMDLINE (kernel cmdline extras)
#          GPU_ENV_VARS (space-separated VAR=value pairs)
# Returns: 0 on success, 3 on unknown GPU
detect_gpu() {
    # Honor manual override (--gpu= flag or GPU_OVERRIDE env)
    if [[ -n "${GPU_OVERRIDE:-}" ]]; then
        export GPU_TYPE="$GPU_OVERRIDE"
        log_info "GPU override: $GPU_TYPE"
        printf '%s\n' "$GPU_TYPE"
        return 0
    fi

    local db_file="$REPO_ROOT/source/detect/gpu-db.psv"
    if [[ ! -f "$db_file" ]]; then
        log_err "gpu-db.psv not found at $db_file"
        return 3
    fi

    # Use LSPCI_OVERRIDE for testing, otherwise real lspci
    local lspci_output
    if [[ -n "${LSPCI_OVERRIDE:-}" ]]; then
        lspci_output="[${LSPCI_OVERRIDE}]"
    else
        lspci_output="$(lspci -nn -d ::0300 2>/dev/null; lspci -nn -d ::0302 2>/dev/null)"
    fi

    local matches=()
    local matched_pkg="" matched_cmdline="" matched_env=""
    while IFS='|' read -r prefix gen pkg_list cmdline env_vars; do
        [[ "$prefix" =~ ^#.*$ || -z "$prefix" ]] && continue
        if printf '%s\n' "$lspci_output" | grep -qi "\[${prefix}"; then
            matches+=("$gen")
            matched_pkg="$pkg_list"
            matched_cmdline="$cmdline"
            matched_env="$env_vars"
        fi
    done < "$db_file"

    if [[ ${#matches[@]} -eq 0 ]]; then
        export GPU_TYPE="unknown"
        log_warn "GPU not recognized — use --gpu=nvidia|amd|intel|hybrid to override"
        printf 'unknown\n'
        return 3
    elif [[ ${#matches[@]} -gt 1 ]]; then
        local first="${matches[0]}" second="${matches[1]}"
        if [[ "$first" == amd-* || "$second" == amd-* ]]; then
            export GPU_TYPE="hybrid-amd"
        else
            export GPU_TYPE="hybrid"
        fi
    else
        export GPU_TYPE="${matches[0]}"
    fi

    export GPU_PKG_LIST="$matched_pkg"
    export GPU_CMDLINE="$matched_cmdline"
    export GPU_ENV_VARS="$matched_env"

    log_info "GPU detected: $GPU_TYPE"
    printf '%s\n' "$GPU_TYPE"
    return 0
}

# detect_cpu — returns "intel" or "amd"
detect_cpu() {
    local vendor
    vendor="$(lscpu 2>/dev/null | awk '/^Vendor ID:/ {print tolower($3)}')"
    case "$vendor" in
        *genuineintel*|*intel*) export CPU_VENDOR="intel"; printf 'intel\n'; return 0 ;;
        *authenticamd*|*amd*)   export CPU_VENDOR="amd";   printf 'amd\n';   return 0 ;;
        *)
            if grep -qi "intel" /proc/cpuinfo 2>/dev/null; then
                export CPU_VENDOR="intel"; printf 'intel\n'
            elif grep -qi "amd" /proc/cpuinfo 2>/dev/null; then
                export CPU_VENDOR="amd"; printf 'amd\n'
            else
                export CPU_VENDOR="unknown"; printf 'unknown\n'
            fi
            ;;
    esac
}

# detect_wifi — returns kernel module name or "none"
detect_wifi() {
    local module
    module="$(lspci -v 2>/dev/null | awk '/Network controller/{found=1} found && /Kernel driver/{print $NF; found=0; exit}')"
    export WIFI_MODULE="${module:-none}"
    printf '%s\n' "${module:-none}"
}

# detect_battery — returns 0 if battery present, 1 if desktop/no battery
detect_battery() {
    if compgen -G "/sys/class/power_supply/BAT*" > /dev/null 2>&1; then
        export HAS_BATTERY=1
        return 0
    fi
    export HAS_BATTERY=0
    return 1
}

# detect_bluetooth — returns 0 if BT hardware present, 1 if not
detect_bluetooth() {
    if lsusb 2>/dev/null | grep -qi "bluetooth" || hciconfig 2>/dev/null | grep -q "hci"; then
        export HAS_BLUETOOTH=1
        return 0
    fi
    export HAS_BLUETOOTH=0
    return 1
}

# detect_bootloader — returns grub | systemd-boot | refind | unknown
detect_bootloader() {
    local result="unknown"
    if [[ -d /boot/grub && -f /boot/grub/grub.cfg ]]; then
        result="grub"
    elif [[ -d /boot/loader && -f /boot/loader/loader.conf ]]; then
        result="systemd-boot"
    elif [[ -f /boot/refind_linux.conf ]] || \
         find /boot/EFI -name "refind*.efi" &>/dev/null; then
        result="refind"
    fi
    export BOOTLOADER="$result"
    printf '%s\n' "$result"
}

# detect_kernels — list of installed kernel pkgbase names
detect_kernels() {
    local kernels=()
    for dir in /usr/lib/modules/*/pkgbase; do
        [[ -f "$dir" ]] && kernels+=("$(cat "$dir")")
    done
    export KERNELS=("${kernels[@]}")
    printf '%s\n' "${kernels[@]}"
}

# detect_aur_helper — returns paru | yay, bootstraps yay if neither found
detect_aur_helper() {
    if command -v paru &>/dev/null; then
        export AUR_HELPER="paru"
        printf 'paru\n'
        return 0
    fi
    if command -v yay &>/dev/null; then
        export AUR_HELPER="yay"
        printf 'yay\n'
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_warn "[dry-run] no AUR helper found; would bootstrap yay"
        export AUR_HELPER="yay"
        printf 'yay\n'
        return 0
    fi
    log_warn "No AUR helper found — bootstrapping yay..."
    # makepkg requires base-devel (fakeroot, debugedit, patch, ...). On a base
    # Arch install these are missing, so ensure them before the build step.
    if ! command -v fakeroot &>/dev/null || ! command -v debugedit &>/dev/null; then
        log_info "installing base-devel (required for makepkg)..."
        sudo pacman -S --noconfirm --needed --disable-download-timeout base-devel \
            && log_ok "base-devel installed" \
            || { log_err "base-devel install failed — cannot bootstrap yay"; return 1; }
    fi
    local tmpdir
    tmpdir="$(mktemp -d)"
    git clone --depth=1 https://aur.archlinux.org/yay.git "$tmpdir/yay" \
        || { log_err "git clone yay failed"; rm -rf "$tmpdir"; return 1; }
    ( cd "$tmpdir/yay" && makepkg -si --noconfirm ) \
        || { log_err "makepkg yay failed"; rm -rf "$tmpdir"; return 1; }
    rm -rf "$tmpdir"
    export AUR_HELPER="yay"
    printf 'yay\n'
}

# symlink_safe <src> <dst>
# Creates symlink dst → src. Handles conflicts via ON_CONFLICT env var:
#   overwrite — remove existing dst, replace with symlink
#   skip      — leave existing dst in place, return 0
#   abort     — return 1 immediately
#   (default interactive: 10s timed prompt)
symlink_safe() {
    local src="$1" dst="$2"
    local conflict="${ON_CONFLICT:-}"

    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ -z "$conflict" ]]; then
            local choice
            choice="$(prompt_timer 10 "Conflict at $dst — [o]verwrite/[s]kip/[a]bort?" "s")"
            case "${choice,,}" in
                o*) conflict="overwrite" ;;
                a*) conflict="abort" ;;
                *)  conflict="skip" ;;
            esac
        fi
        case "$conflict" in
            overwrite)
                if [[ "${DRY_RUN:-0}" != "1" ]]; then
                    if [[ -L "$dst" || -f "$dst" ]]; then
                        rm "$dst"
                    elif [[ -d "$dst" ]]; then
                        log_err "refusing to remove real directory: $dst (use ON_CONFLICT=skip or remove manually)"
                        return 1
                    fi
                fi
                log_warn "overwriting: $dst"
                ;;
            skip)
                log_skip "skipping existing: $dst"
                return 0
                ;;
            abort)
                log_err "conflict at $dst — aborting"
                return 1
                ;;
        esac
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would symlink: $dst → $src"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    log_ok "linked: $dst → $src"
}
