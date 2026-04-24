#!/usr/bin/env bash
# wired-dots — entry point wrapper
# Delegates to scripts/install.sh
# See: docs/superpowers/specs/ for design, docs/ for user docs

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$REPO_ROOT/scripts/install.sh" "$@"
