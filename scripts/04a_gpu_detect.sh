#!/usr/bin/env bash
# wired-dots — phase 04a: GPU type detection
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

ensure_gpu_type() {
    if [[ -n "${GPU_TYPE:-}" && -z "${GPU_OVERRIDE:-}" ]]; then
        log_skip "GPU_TYPE already set: ${GPU_TYPE}"
        return 0
    fi

    if [[ -n "${GPU_OVERRIDE:-}" ]]; then
        export GPU_TYPE="$GPU_OVERRIDE"
        log_info "GPU override applied: $GPU_TYPE"
        return 0
    fi

    detect_gpu || {
        log_warn "GPU detection failed — GPU_TYPE=unknown. Use --gpu= to override."
        export GPU_TYPE="unknown"
    }
}

main() {
    log_step "04a" "GPU detect"
    ensure_gpu_type
    log_ok "GPU type: ${GPU_TYPE:-unknown}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
