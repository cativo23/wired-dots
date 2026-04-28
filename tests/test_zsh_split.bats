#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export WIRED_LOG_FILE="/dev/null"
    export NONINTERACTIVE=1
    export ON_CONFLICT="overwrite"
    # Stage a per-test repo so deploy_zsh symlinks point inside our sandbox.
    export STAGE="$TEST_TMP/repo"
    mkdir -p "$STAGE/scripts" "$STAGE/zsh"
    cp "$REPO_ROOT/scripts/global_fn.sh" "$STAGE/scripts/"
    cp "$REPO_ROOT/scripts/06_symlinks.sh" "$STAGE/scripts/"
    cp "$REPO_ROOT/zsh/.zshrc"                 "$STAGE/zsh/"
    cp "$REPO_ROOT/zsh/wired-defaults.zsh"     "$STAGE/zsh/"
    cp "$REPO_ROOT/zsh/user.zsh.example"       "$STAGE/zsh/"
    cp "$REPO_ROOT/zsh/user.local.zsh.example" "$STAGE/zsh/"
}

teardown() { rm -rf "$TEST_TMP"; }

run_deploy() {
    REPO_ROOT="$STAGE" run bash -c "
        export REPO_ROOT='$STAGE' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               NONINTERACTIVE=1 ON_CONFLICT=overwrite
        source '$STAGE/scripts/06_symlinks.sh'
        DRY_RUN=0 deploy_zsh
    "
}

@test "deploy_zsh symlinks .zshrc and wired-defaults.zsh from repo" {
    run_deploy
    [ "$status" -eq 0 ]
    [ -L "$HOME/.config/zsh/.zshrc" ]
    [ -L "$HOME/.config/zsh/wired-defaults.zsh" ]
    [ "$(readlink -f "$HOME/.config/zsh/.zshrc")" = "$STAGE/zsh/.zshrc" ]
}

@test "deploy_zsh seeds user.zsh from template on first install" {
    run_deploy
    [ "$status" -eq 0 ]
    # Real file, not a symlink — owned by the user post-install
    [ -f "$HOME/.config/zsh/user.zsh" ]
    [ ! -L "$HOME/.config/zsh/user.zsh" ]
    diff -q "$HOME/.config/zsh/user.zsh" "$STAGE/zsh/user.zsh.example"
}

@test "deploy_zsh seeds user.local.zsh on first install" {
    run_deploy
    [ "$status" -eq 0 ]
    [ -f "$HOME/.config/zsh/user.local.zsh" ]
    [ ! -L "$HOME/.config/zsh/user.local.zsh" ]
}

@test "deploy_zsh does NOT overwrite an existing user.zsh on re-run" {
    mkdir -p "$HOME/.config/zsh"
    printf '# my custom zshrc — should survive\nalias me=mine\n' > "$HOME/.config/zsh/user.zsh"
    local sentinel; sentinel="$(md5sum "$HOME/.config/zsh/user.zsh" | awk '{print $1}')"

    run_deploy
    [ "$status" -eq 0 ]
    local after; after="$(md5sum "$HOME/.config/zsh/user.zsh" | awk '{print $1}')"
    [ "$sentinel" = "$after" ]
}

@test "deploy_zsh DRY_RUN=1 creates nothing" {
    REPO_ROOT="$STAGE" run bash -c "
        export REPO_ROOT='$STAGE' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               NONINTERACTIVE=1 ON_CONFLICT=overwrite
        source '$STAGE/scripts/06_symlinks.sh'
        DRY_RUN=1 deploy_zsh
    "
    [ "$status" -eq 0 ]
    [ ! -e "$HOME/.config/zsh/.zshrc" ]
    [ ! -e "$HOME/.config/zsh/user.zsh" ]
}

@test "user.zsh.example contains the cdp/cdw aliases" {
    grep -q "alias cdp=" "$REPO_ROOT/zsh/user.zsh.example"
    grep -q "alias cdw=" "$REPO_ROOT/zsh/user.zsh.example"
    grep -q "mkpersonal()" "$REPO_ROOT/zsh/user.zsh.example"
}

@test "wired-defaults.zsh contains framework infrastructure" {
    grep -q "fastfetch" "$REPO_ROOT/zsh/wired-defaults.zsh"
    grep -q "EDITOR" "$REPO_ROOT/zsh/wired-defaults.zsh"
    grep -q "init-nvm.sh" "$REPO_ROOT/zsh/wired-defaults.zsh"
}

@test "wired-defaults.zsh does NOT contain user-specific paths" {
    # cdp/cdw and ~/projects/* belong in user.zsh, not in defaults
    ! grep -qE "cdp=|cdw=|~/projects/" "$REPO_ROOT/zsh/wired-defaults.zsh"
}

@test ".zshrc sources both wired-defaults and user.zsh in the right order" {
    local rc="$REPO_ROOT/zsh/.zshrc"
    grep -q "wired-defaults.zsh"  "$rc"
    grep -q "user.zsh"            "$rc"
    # wired-defaults must come first (earlier line number)
    local wd_line user_line
    wd_line=$(  grep -n "wired-defaults.zsh" "$rc" | head -1 | cut -d: -f1)
    user_line=$(grep -n '"\${ZDOTDIR.*}/user.zsh"' "$rc" | head -1 | cut -d: -f1)
    [ "$wd_line" -lt "$user_line" ]
}
