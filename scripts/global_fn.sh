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

export WIRED_DOTS_VERSION
WIRED_DOTS_VERSION="$(cat "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../VERSION" 2>/dev/null || printf 'unknown\n')"

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
    sudo -v
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
