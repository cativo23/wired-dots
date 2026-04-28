#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export XDG_CACHE_HOME="$TEST_TMP/.cache"
    export WIRED_LOG_FILE="/dev/null"
    export NONINTERACTIVE=1
    # Stage a per-test repo so the phase script can write hypr/local-overrides.conf
    # without dirtying the real worktree.
    export STAGE="$TEST_TMP/repo"
    mkdir -p "$STAGE/scripts" "$STAGE/hypr"
    cp "$REPO_ROOT/scripts/global_fn.sh" "$STAGE/scripts/"
    cp "$REPO_ROOT/scripts/02b_user_choices.sh" "$STAGE/scripts/"
}

teardown() { rm -rf "$TEST_TMP"; }

run_phase() {
    REPO_ROOT="$STAGE" run bash -c "
        export REPO_ROOT='$STAGE' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               XDG_CACHE_HOME='$XDG_CACHE_HOME' NONINTERACTIVE=1 \
               KB_LAYOUT='$1' WIRED_BROWSER='$2' WIRED_FILE_MANAGER='$3' \
               DRY_RUN='${4:-0}'
        bash '$STAGE/scripts/02b_user_choices.sh'
    "
}

@test "02b writes choices file with KEY=VALUE entries" {
    run_phase us brave-bin dolphin
    [ "$status" -eq 0 ]
    [ -f "$XDG_CACHE_HOME/wired-dots/user-choices.conf" ]
    grep -q "^KB_LAYOUT=us$"             "$XDG_CACHE_HOME/wired-dots/user-choices.conf"
    grep -q "^BROWSER=brave-bin$"        "$XDG_CACHE_HOME/wired-dots/user-choices.conf"
    grep -q "^FILE_MANAGER=dolphin$"     "$XDG_CACHE_HOME/wired-dots/user-choices.conf"
}

@test "02b writes hypr/local-overrides.conf with vars + input block" {
    run_phase "latam,us" firefox thunar
    [ "$status" -eq 0 ]
    [ -f "$STAGE/hypr/local-overrides.conf" ]
    grep -q '^\$BROWSER = firefox$'        "$STAGE/hypr/local-overrides.conf"
    grep -q '^\$FILE_MANAGER = thunar$'    "$STAGE/hypr/local-overrides.conf"
    grep -q 'kb_layout = latam,us'         "$STAGE/hypr/local-overrides.conf"
}

@test "02b DRY_RUN=1 produces no files" {
    run_phase us brave-bin dolphin 1
    [ "$status" -eq 0 ]
    [ ! -f "$XDG_CACHE_HOME/wired-dots/user-choices.conf" ]
    [ ! -f "$STAGE/hypr/local-overrides.conf" ]
}

@test "02b translates brave-bin → brave in hypr overrides" {
    run_phase us brave-bin dolphin
    [ "$status" -eq 0 ]
    grep -q '^\$BROWSER = brave$' "$STAGE/hypr/local-overrides.conf"
    # The choices file keeps the package-canonical name unchanged
    grep -q '^BROWSER=brave-bin$'  "$XDG_CACHE_HOME/wired-dots/user-choices.conf"
}

@test "02b translates pcmanfm-gtk3 → pcmanfm in hypr overrides" {
    run_phase us firefox pcmanfm-gtk3
    [ "$status" -eq 0 ]
    grep -q '^\$FILE_MANAGER = pcmanfm$' "$STAGE/hypr/local-overrides.conf"
    grep -q '^FILE_MANAGER=pcmanfm-gtk3$' "$XDG_CACHE_HOME/wired-dots/user-choices.conf"
}

@test "02b errors when required env var missing" {
    REPO_ROOT="$STAGE" run bash -c "
        export REPO_ROOT='$STAGE' WIRED_LOG_FILE=/dev/null HOME='$TEST_TMP' \
               XDG_CACHE_HOME='$XDG_CACHE_HOME' NONINTERACTIVE=1
        # KB_LAYOUT, WIRED_BROWSER, WIRED_FILE_MANAGER intentionally unset
        bash '$STAGE/scripts/02b_user_choices.sh'
    "
    [ "$status" -ne 0 ]
}
