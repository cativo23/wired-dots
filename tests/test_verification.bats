#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export WIRED_LOG_FILE="/dev/null"
    export NONINTERACTIVE=1
    source "$REPO_ROOT/scripts/global_fn.sh"
    source "$REPO_ROOT/scripts/10c_verification.sh"
}

teardown() { rm -rf "$TEST_TMP"; }

@test "check_managed_path: whole-dir symlink resolves → returns 0" {
    local target="$TEST_TMP/real_dir"
    mkdir -p "$target"
    ln -s "$target" "$TEST_TMP/the_link"
    run check_managed_path "$TEST_TMP/the_link" ""
    [ "$status" -eq 0 ]
}

@test "check_managed_path: real dir with valid sentinel symlink → returns 0" {
    local target_file="$TEST_TMP/repo/wired-defaults.zsh"
    mkdir -p "$TEST_TMP/repo"
    printf '# stub\n' > "$target_file"
    local zsh_dir="$TEST_TMP/.config/zsh"
    mkdir -p "$zsh_dir"
    ln -s "$target_file" "$zsh_dir/wired-defaults.zsh"
    # No sentinel empty-string path: call with the sentinel
    run check_managed_path "$zsh_dir" "$zsh_dir/wired-defaults.zsh"
    [ "$status" -eq 0 ]
}

@test "check_managed_path: real dir without valid sentinel (empty sentinel) → returns 1" {
    local plain_dir="$TEST_TMP/.config/kitty"
    mkdir -p "$plain_dir"
    # kitty uses whole-dir symlink; a real dir with no sentinel means broken
    run check_managed_path "$plain_dir" ""
    [ "$status" -eq 1 ]
}

@test "check_managed_path: missing path → returns 1" {
    run check_managed_path "$TEST_TMP/does_not_exist" ""
    [ "$status" -eq 1 ]
}

@test "check_managed_path: broken symlink (target gone) → returns 1" {
    ln -s "$TEST_TMP/nonexistent_target" "$TEST_TMP/broken_link"
    run check_managed_path "$TEST_TMP/broken_link" ""
    [ "$status" -eq 1 ]
}
