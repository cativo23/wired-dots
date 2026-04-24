#!/usr/bin/env bash
# wired-dots — installer orchestrator
# Full phase execution implemented in M2+.

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
# shellcheck disable=SC1091
# global_fn.sh is loaded lazily in real phases; unused in M0 stub.
# source "$SCRIPTS_DIR/global_fn.sh"

print_help() {
    cat <<'EOF'
wired-dots v0.1.0-dev
A cyberpunk Hyprland setup for Arch — Tokyo Night aesthetic.

USAGE
  ./install.sh [FLAGS]

Currently this is an M0 scaffolding stub. Full flags arrive in M2+.

See docs/ and the design spec for the planned behavior.
EOF
}

print_version() {
    cat "$REPO_ROOT/VERSION"
}

main() {
    case "${1:-}" in
        --help|-h) print_help; exit 0 ;;
        --version|-v) print_version; exit 0 ;;
        "") print_help; exit 1 ;;
        *) echo "wired-dots: installer not implemented yet (M0 scaffolding). Got flag: $1" >&2
           echo "Try: $0 --help" >&2
           exit 1 ;;
    esac
}

main "$@"
