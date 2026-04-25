#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "07_theme sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/07_theme.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "apply_gtk_theme DRY_RUN=1 logs without calling gsettings" {
    source "$REPO_ROOT/scripts/07_theme.sh"
    DRY_RUN=1 run apply_gtk_theme
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
    [[ "$output" != *"Error"* ]]
}

@test "apply_cursor_theme DRY_RUN=1 logs without calling gsettings" {
    source "$REPO_ROOT/scripts/07_theme.sh"
    DRY_RUN=1 run apply_cursor_theme
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}

@test "main DRY_RUN=1 completes without real gsettings" {
    source "$REPO_ROOT/scripts/07_theme.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}
