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
WIRED_DOTS_VERSION="$(cat "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../VERSION" 2>/dev/null || echo "unknown")"

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
    printf '%s\n' "$symbol $msg" >> "$log_file" 2>/dev/null || true
}

log_ok()   { print_log "$WIRED_COLOR_GREEN"  "✓" "$*"; }
log_warn() { print_log "$WIRED_COLOR_YELLOW" "⚠" "$*"; }
log_err()  { print_log "$WIRED_COLOR_RED"    "✗" "$*"; }
log_skip() { print_log "$WIRED_COLOR_MUTED"  "○" "$*"; }
log_info() { print_log "$WIRED_COLOR_BLUE"   "ℹ" "$*"; }
log_step() { print_log "$WIRED_COLOR_BLUE"   "▶" "$1 $2"; }
