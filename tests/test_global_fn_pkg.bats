#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "pkg_installed returns 0 for bash (always installed on Arch)" {
    run pkg_installed "bash"
    [ "$status" -eq 0 ]
}

@test "pkg_installed returns 1 for a package that cannot exist" {
    run pkg_installed "wired-dots-definitely-not-a-real-package-xyz123"
    [ "$status" -eq 1 ]
}

@test "pkg_available returns 0 for bash (in core repo)" {
    if [[ ! -f /var/lib/pacman/sync/core.db ]]; then
        skip "pacman sync DB not available"
    fi
    run pkg_available "bash"
    [ "$status" -eq 0 ]
}

@test "pkg_available returns 1 for non-existent package" {
    if [[ ! -f /var/lib/pacman/sync/core.db ]]; then
        skip "pacman sync DB not available"
    fi
    run pkg_available "wired-dots-definitely-not-a-real-package-xyz123"
    [ "$status" -eq 1 ]
}
