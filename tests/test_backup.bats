#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export WIRED_LOG="test-run"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

teardown() { rm -rf "$TEST_TMP"; }

@test "backup_configs skips entirely in DRY_RUN=1" {
    source "$REPO_ROOT/scripts/01_backup.sh"
    DRY_RUN=1 run backup_configs
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_TMP/.local/share/wired-dots" ]
}

@test "backup_configs copies a real directory" {
    source "$REPO_ROOT/scripts/01_backup.sh"
    mkdir -p "$TEST_TMP/.config/hypr"
    printf 'monitor=,preferred,auto,1\n' > "$TEST_TMP/.config/hypr/hyprland.conf"
    DRY_RUN=0 run backup_configs
    [ "$status" -eq 0 ]
    [ -d "$TEST_TMP/.local/share/wired-dots/backups/test-run/hypr" ]
}

@test "backup_configs skips symlinks (already managed)" {
    source "$REPO_ROOT/scripts/01_backup.sh"
    mkdir -p "$TEST_TMP/.config/src_hypr"
    ln -s "$TEST_TMP/.config/src_hypr" "$TEST_TMP/.config/hypr"
    DRY_RUN=0 run backup_configs
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_TMP/.local/share/wired-dots/backups/test-run/hypr" ]
}

@test "backup_configs removes empty backup dir when nothing backed up" {
    source "$REPO_ROOT/scripts/01_backup.sh"
    DRY_RUN=0 run backup_configs
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_TMP/.local/share/wired-dots/backups/test-run" ]
}

@test "backup_configs backs up home dotfile .zshenv" {
    source "$REPO_ROOT/scripts/01_backup.sh"
    printf 'export ZDOTDIR="$HOME/.config/zsh"\n' > "$TEST_TMP/.zshenv"
    DRY_RUN=0 run backup_configs
    [ "$status" -eq 0 ]
    [ -f "$TEST_TMP/.local/share/wired-dots/backups/test-run/.zshenv" ]
}
