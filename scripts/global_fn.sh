#!/usr/bin/env bash
# wired-dots — shared installer helpers
# Full implementation in M2. This file only exports palette + version constants for M0.

# Do NOT set -euo pipefail here — this file is sourced.

# Tokyo Night palette (truecolor ANSI 24-bit)
export WIRED_COLOR_BLUE='\033[38;2;122;162;247m'
export WIRED_COLOR_GREEN='\033[38;2;158;206;106m'
export WIRED_COLOR_YELLOW='\033[38;2;224;175;104m'
export WIRED_COLOR_RED='\033[38;2;247;118;142m'
export WIRED_COLOR_PURPLE='\033[38;2;187;154;247m'
export WIRED_COLOR_MUTED='\033[38;2;86;95;137m'
export WIRED_COLOR_RESET='\033[0m'

export WIRED_DOTS_VERSION="0.1.0-dev"

# Per-run log directory identifier — used by real phases once implemented.
: "${WIRED_LOG:=$(date +'%y%m%d_%Hh%Mm%Ss')}"
export WIRED_LOG
