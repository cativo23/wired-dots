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

@test "link_config_dirs no longer creates a whole-dir waybar symlink" {
    # Since PR G waybar/ uses a file-level deploy via deploy_waybar(); the
    # generic CONFIG_DIRS-based whole-dir symlink would conflict with that.
    source "$REPO_ROOT/scripts/06_symlinks.sh"
    DRY_RUN=0 ON_CONFLICT=overwrite run link_config_dirs
    [ "$status" -eq 0 ]
    [ ! -e "$TEST_TMP/.config/waybar" ]
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
# would otherwise touch REPO_ROOT don't dirty the real worktree. Same shape
# as the production layout: waybar/{layouts,styles,modules,includes}.
_stage_repo() {
    local stage="$TEST_TMP/repo"
    mkdir -p "$stage/waybar/layouts" "$stage/waybar/styles" \
             "$stage/waybar/modules" "$stage/waybar/includes" \
             "$stage/scripts" "$stage/source/wallpapers" "$stage/bin"
    cp "$REPO_ROOT/scripts/global_fn.sh" "$stage/scripts/"
    cp "$REPO_ROOT/scripts/06_symlinks.sh" "$stage/scripts/"
    cp "$REPO_ROOT/waybar/layouts/cyberdeck-nerv.jsonc" "$stage/waybar/layouts/"
    cp "$REPO_ROOT/waybar/styles/cyberdeck-nerv.css"   "$stage/waybar/styles/"
    cp "$REPO_ROOT/waybar/styles/defaults.css"          "$stage/waybar/styles/"
    echo "$stage"
}

@test "deploy_waybar materializes file-level symlinks at ~/.config/waybar" {
    local stage; stage="$(_stage_repo)"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               NONINTERACTIVE=1 ON_CONFLICT=overwrite
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_waybar
    "
    [ "$status" -eq 0 ]
    # ~/.config/waybar is now a real directory
    [ -d "$TEST_TMP/.config/waybar" ]
    [ ! -L "$TEST_TMP/.config/waybar" ]
    # Subdirs are symlinked
    [ -L "$TEST_TMP/.config/waybar/layouts" ]
    [ -L "$TEST_TMP/.config/waybar/styles" ]
    # Active layout/style/defaults are file-level symlinks pointing at the
    # canonical sources under styles/ and layouts/
    [ -L "$TEST_TMP/.config/waybar/config.jsonc" ]
    [ -L "$TEST_TMP/.config/waybar/style.css" ]
    [ -L "$TEST_TMP/.config/waybar/defaults.css" ]
    [ "$(readlink -f "$TEST_TMP/.config/waybar/config.jsonc")" = "$stage/waybar/layouts/cyberdeck-nerv.jsonc" ]
    [ "$(readlink -f "$TEST_TMP/.config/waybar/style.css")"    = "$stage/waybar/styles/cyberdeck-nerv.css" ]
}

@test "deploy_waybar does NOT write generated files into the source repo dir" {
    local stage; stage="$(_stage_repo)"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               NONINTERACTIVE=1 ON_CONFLICT=overwrite
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_waybar
    "
    [ "$status" -eq 0 ]
    # The pre-PR-G activate_waybar_layout used to cp into here — must not
    # happen anymore.
    [ ! -e "$stage/waybar/config.jsonc" ]
    [ ! -e "$stage/waybar/style.css" ]
    [ ! -e "$stage/waybar/defaults.css" ]
}

@test "deploy_waybar migrates an existing dir-symlink layout" {
    local stage; stage="$(_stage_repo)"
    # Simulate a pre-PR-G install: ~/.config/waybar is a symlink to repo/waybar
    mkdir -p "$TEST_TMP/.config"
    ln -s "$stage/waybar" "$TEST_TMP/.config/waybar"
    [ -L "$TEST_TMP/.config/waybar" ]

    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               NONINTERACTIVE=1 ON_CONFLICT=overwrite
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_waybar
    "
    [ "$status" -eq 0 ]
    [ -d "$TEST_TMP/.config/waybar" ]
    [ ! -L "$TEST_TMP/.config/waybar" ]
    [ -L "$TEST_TMP/.config/waybar/config.jsonc" ]
}

@test "deploy_waybar DRY_RUN=1 creates nothing" {
    local stage; stage="$(_stage_repo)"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               NONINTERACTIVE=1 ON_CONFLICT=overwrite
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=1 deploy_waybar
    "
    [ "$status" -eq 0 ]
    [ ! -e "$TEST_TMP/.config/waybar" ]
    [ ! -e "$stage/waybar/config.jsonc" ]
}

@test "deploy_wallpapers copies wallpapers from submodule pack/ recursively" {
    local stage; stage="$(_stage_repo)"
    mkdir -p "$stage/source/wallpapers/pack/tokyo-night"
    : > "$stage/source/wallpapers/pack/tokyo-night/aaa.png"
    : > "$stage/source/wallpapers/pack/tokyo-night/bbb.jpg"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    [ -f "$TEST_TMP/.config/wired-dots/wallpapers/aaa.png" ]
    [ -f "$TEST_TMP/.config/wired-dots/wallpapers/bbb.jpg" ]
}

@test "deploy_wallpapers creates current symlink to first wallpaper alphabetically" {
    local stage; stage="$(_stage_repo)"
    mkdir -p "$stage/source/wallpapers/pack/tokyo-night"
    : > "$stage/source/wallpapers/pack/tokyo-night/zzz.png"
    : > "$stage/source/wallpapers/pack/tokyo-night/aaa.png"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    [ -L "$TEST_TMP/.config/wired-dots/current" ]
    target="$(readlink -f "$TEST_TMP/.config/wired-dots/current")"
    [[ "$target" == *"/aaa.png" ]]
}

@test "deploy_wallpapers leaves valid current symlink alone (idempotent)" {
    local stage; stage="$(_stage_repo)"
    mkdir -p "$stage/source/wallpapers/pack/tokyo-night"
    : > "$stage/source/wallpapers/pack/tokyo-night/aaa.png"
    : > "$stage/source/wallpapers/pack/tokyo-night/bbb.png"
    mkdir -p "$TEST_TMP/.config/wired-dots/wallpapers"
    : > "$TEST_TMP/.config/wired-dots/wallpapers/bbb.png"
    ln -s "$TEST_TMP/.config/wired-dots/wallpapers/bbb.png" "$TEST_TMP/.config/wired-dots/current"

    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    target="$(readlink -f "$TEST_TMP/.config/wired-dots/current")"
    [[ "$target" == *"/bbb.png" ]]  # preserved user choice, not reset to alphabetical first
}

@test "deploy_wallpapers magick fallback when source/wallpapers/ has no images" {
    local stage; stage="$(_stage_repo)"
    # source/wallpapers/ exists in stage but has no image files (submodule not cloned)
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    if command -v magick >/dev/null 2>&1; then
        [ -f "$TEST_TMP/.config/wired-dots/wallpapers/tokyo-night-default.png" ]
        [[ "$output" == *"submodule not cloned"* ]]
    fi
}

@test "deploy_wallpapers DRY_RUN=1 creates nothing" {
    local stage; stage="$(_stage_repo)"
    mkdir -p "$stage/source/wallpapers/pack/tokyo-night"
    : > "$stage/source/wallpapers/pack/tokyo-night/aaa.png"
    REPO_ROOT="$stage" run bash -c "
        export REPO_ROOT='$stage' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' NONINTERACTIVE=1
        source '$stage/scripts/06_symlinks.sh'
        DRY_RUN=1 deploy_wallpapers
    "
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_TMP/.config/wired-dots/wallpapers" ]
    [ ! -L "$TEST_TMP/.config/wired-dots/current" ]
}
