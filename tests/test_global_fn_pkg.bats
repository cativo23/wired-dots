#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "pkg_installed returns 0 for bash (always installed on Arch)" {
    command -v pacman >/dev/null 2>&1 || skip "pacman not available (non-Arch CI)"
    run pkg_installed "bash"
    [ "$status" -eq 0 ]
}

@test "pkg_installed returns 1 for a package that cannot exist" {
    command -v pacman >/dev/null 2>&1 || skip "pacman not available (non-Arch CI)"
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

@test "sentinel_check returns 2 (not applied) for file without .wired.bkp" {
    local tmp
    tmp="$(mktemp)"
    printf 'some content\n' > "$tmp"
    run sentinel_check "$tmp"
    [ "$status" -eq 2 ]
    rm -f "$tmp" "${tmp}.wired.bkp"
}

@test "sentinel_check returns 0 (already applied) when hash matches" {
    local tmp
    tmp="$(mktemp)"
    printf 'patched content\n' > "$tmp"
    sha256sum "$tmp" | awk '{print $1}' > "${tmp}.wired.bkp"
    run sentinel_check "$tmp"
    [ "$status" -eq 0 ]
    rm -f "$tmp" "${tmp}.wired.bkp"
}

@test "sentinel_check returns 1 (drift) when file changed since last apply" {
    local tmp
    tmp="$(mktemp)"
    printf 'original content\n' > "$tmp"
    printf 'different-hash\n' > "${tmp}.wired.bkp"
    run sentinel_check "$tmp"
    [ "$status" -eq 1 ]
    rm -f "$tmp" "${tmp}.wired.bkp"
}
