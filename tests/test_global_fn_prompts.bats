#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
    export WIRED_LOG_FILE="/dev/null"
}

@test "confirm returns 0 for 'y' default in NONINTERACTIVE mode" {
    NONINTERACTIVE=1 run confirm "Install packages?" "y" 5
    [ "$status" -eq 0 ]
}

@test "confirm returns 1 for 'n' default in NONINTERACTIVE mode" {
    NONINTERACTIVE=1 run confirm "Remove files?" "n" 5
    [ "$status" -eq 1 ]
}

@test "prompt_timer returns default 'y' in NONINTERACTIVE mode" {
    NONINTERACTIVE=1 run prompt_timer 5 "Continue?" "y"
    [ "$status" -eq 0 ]
    [[ "$output" == "y" ]]
}

@test "prompt_timer returns default 'n' in NONINTERACTIVE mode" {
    NONINTERACTIVE=1 run prompt_timer 5 "Abort?" "n"
    [ "$status" -eq 0 ]
    [[ "$output" == "n" ]]
}

@test "require_sudo short-circuits in DRY_RUN mode" {
    DRY_RUN=1 run require_sudo
    [ "$status" -eq 0 ]
}

@test "stop_sudo_keepalive cleans up without error when no keepalive running" {
    unset SUDO_KEEPALIVE_PID
    run stop_sudo_keepalive
    [ "$status" -eq 0 ]
}
