#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export WIRED_LOG_FILE="/dev/null"
    export ON_CONFLICT="skip"
    export NONINTERACTIVE=1
    source "$REPO_ROOT/scripts/global_fn.sh"
}

teardown() { rm -rf "$TEST_TMP"; }

@test "06_symlinks sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null HOME=\"$TEST_TMP\" NONINTERACTIVE=1 ON_CONFLICT=skip
        source \"$REPO_ROOT/scripts/06_symlinks.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "link_config_dirs creates ~/.config/hypr symlink" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=0 ON_CONFLICT=overwrite run link_config_dirs
    [ "$status" -eq 0 ]
    [ -L "$TEST_TMP/.config/hypr" ]
}

@test "link_config_dirs creates ~/.config/waybar symlink" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=0 ON_CONFLICT=overwrite run link_config_dirs
    [ "$status" -eq 0 ]
    [ -L "$TEST_TMP/.config/waybar" ]
}

@test "link_home_dotfiles skips gracefully when home/ is empty" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=0 ON_CONFLICT=overwrite run link_home_dotfiles
    [ "$status" -eq 0 ]
}

@test "link_bin_files creates individual symlinks in ~/.local/bin/" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=0 ON_CONFLICT=overwrite run link_bin_files
    [ "$status" -eq 0 ]
    local bin_count
    bin_count="$(find "$TEST_TMP/.local/bin" -maxdepth 1 -type l 2>/dev/null | wc -l)"
    [ "$bin_count" -gt 0 ]
}

@test "DRY_RUN=1 creates no symlinks" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=1 run link_config_dirs
    [ "$status" -eq 0 ]
    [ ! -L "$TEST_TMP/.config/hypr" ]
}

@test "link_system_assets DRY_RUN=1 logs without sudo" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=1 run link_system_assets
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}
