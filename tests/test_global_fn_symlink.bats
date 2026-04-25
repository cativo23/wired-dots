#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
    TEST_TMP="$(mktemp -d)"
    export TEST_TMP
}

teardown() {
    rm -rf "$TEST_TMP"
}

@test "symlink_safe creates symlink when destination does not exist" {
    local src="$TEST_TMP/source_dir"
    local dst="$TEST_TMP/link_target"
    mkdir -p "$src"
    NONINTERACTIVE=1 ON_CONFLICT=overwrite run symlink_safe "$src" "$dst"
    [ "$status" -eq 0 ]
    [ -L "$dst" ]
}

@test "symlink_safe overwrites existing file when ON_CONFLICT=overwrite" {
    local src="$TEST_TMP/source_dir"
    local dst="$TEST_TMP/existing"
    mkdir -p "$src"
    mkdir -p "$dst"
    NONINTERACTIVE=1 ON_CONFLICT=overwrite run symlink_safe "$src" "$dst"
    [ "$status" -eq 0 ]
    [ -L "$dst" ]
}

@test "symlink_safe skips when ON_CONFLICT=skip" {
    local src="$TEST_TMP/source_dir"
    local dst="$TEST_TMP/existing"
    mkdir -p "$src"
    mkdir -p "$dst"
    NONINTERACTIVE=1 ON_CONFLICT=skip run symlink_safe "$src" "$dst"
    [ "$status" -eq 0 ]
    [ ! -L "$dst" ]
}

@test "symlink_safe exits 1 when ON_CONFLICT=abort" {
    local src="$TEST_TMP/source_dir"
    local dst="$TEST_TMP/existing"
    mkdir -p "$src"
    mkdir -p "$dst"
    NONINTERACTIVE=1 ON_CONFLICT=abort run symlink_safe "$src" "$dst"
    [ "$status" -eq 1 ]
}
