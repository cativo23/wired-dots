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

@test "link_bin_files skips gracefully when bin/ is empty" {
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=0 ON_CONFLICT=overwrite run link_bin_files
    [ "$status" -eq 0 ]
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

# Helper: stage an isolated repo tree under TEST_TMP/repo so functions that
# write into REPO_ROOT (activate_waybar_layout) don't dirty the real worktree.
_stage_repo() {
    local stage="$TEST_TMP/repo"
    mkdir -p "$stage/waybar/layouts" "$stage/waybar/styles" "$stage/scripts" \
             "$stage/source/wallpapers" "$stage/bin"
    cp "$REPO_ROOT/scripts/global_fn.sh" "$stage/scripts/"
    cp "$REPO_ROOT/scripts/06_symlinks.sh" "$stage/scripts/"
    cp "$REPO_ROOT/waybar/layouts/cyberdeck-nerv.jsonc" "$stage/waybar/layouts/"
    cp "$REPO_ROOT/waybar/styles/cyberdeck-nerv.css"   "$stage/waybar/styles/"
    cp "$REPO_ROOT/waybar/styles/defaults.css"          "$stage/waybar/styles/"
    echo "$stage"
}

@test "activate_waybar_layout materializes config.jsonc, style.css, defaults.css" {
    local stage; stage="$(_stage_repo)"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 activate_waybar_layout
    "
    [ "$status" -eq 0 ]
    [ -f "$stage/waybar/config.jsonc" ]
    [ -f "$stage/waybar/style.css" ]
    [ -f "$stage/waybar/defaults.css" ]
}

@test "activate_waybar_layout style.css matches styles/cyberdeck-nerv.css (not concat)" {
    local stage; stage="$(_stage_repo)"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 activate_waybar_layout
    "
    [ "$status" -eq 0 ]
    diff -q "$stage/waybar/style.css" "$stage/waybar/styles/cyberdeck-nerv.css"
}

@test "activate_waybar_layout DRY_RUN=1 creates no files" {
    local stage; stage="$(_stage_repo)"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=1 activate_waybar_layout
    "
    [ "$status" -eq 0 ]
    [ ! -f "$stage/waybar/config.jsonc" ]
    [ ! -f "$stage/waybar/style.css" ]
    [ ! -f "$stage/waybar/defaults.css" ]
}

@test "deploy_wallpapers copies shipped wallpapers to ~/.config/wired-dots/wallpapers" {
    local stage; stage="$(_stage_repo)"
    : > "$stage/source/wallpapers/tokyo-night-default.png"  # fixture
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    [ -f "$TEST_TMP/.config/wired-dots/wallpapers/tokyo-night-default.png" ]
}

@test "deploy_wallpapers DRY_RUN=1 creates nothing" {
    local stage; stage="$(_stage_repo)"
    : > "$stage/source/wallpapers/tokyo-night-default.png"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=1 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_TMP/.config/wired-dots/wallpapers" ]
}
