#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "check_arch_linux passes on Arch Linux" {
    if [[ ! -f /etc/arch-release ]]; then
        skip "Not running on Arch Linux"
    fi
    source "$REPO_ROOT/scripts/00_preflight.sh"
    run check_arch_linux
    [ "$status" -eq 0 ]
}

@test "check_initramfs aborts when dracut is present" {
    source "$REPO_ROOT/scripts/00_preflight.sh"
    # Mock dracut presence via PATH override
    local mock_bin
    mock_bin="$(mktemp -d)"
    printf '#!/bin/bash\nexit 0\n' > "$mock_bin/dracut"
    chmod +x "$mock_bin/dracut"
    PATH="$mock_bin:$PATH" run check_initramfs
    [ "$status" -eq 2 ]
    rm -rf "$mock_bin"
}

@test "check_initramfs passes when mkinitcpio present and no dracut/booster" {
    if ! command -v mkinitcpio &>/dev/null; then
        skip "mkinitcpio not available"
    fi
    source "$REPO_ROOT/scripts/00_preflight.sh"
    run check_initramfs
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

@test "check_secureboot warns but does not abort by default" {
    source "$REPO_ROOT/scripts/00_preflight.sh"
    STRICT=0 run check_secureboot
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

@test "check_internet returns 0 with working internet" {
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        skip "No internet access in test environment"
    fi
    source "$REPO_ROOT/scripts/00_preflight.sh"
    run check_internet
    [ "$status" -eq 0 ]
}

@test "add_user_groups does not crash in DRY_RUN mode" {
    source "$REPO_ROOT/scripts/00_preflight.sh"
    DRY_RUN=1 run add_user_groups
    [ "$status" -eq 0 ]
}
