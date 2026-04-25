#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "08_sddm sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/08_sddm.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "08_sddm DRY_RUN=1 completes without sudo" {
    source "$REPO_ROOT/scripts/08_sddm.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}

@test "write_sddm_conf DRY_RUN=1 logs config path" {
    source "$REPO_ROOT/scripts/08_sddm.sh"
    DRY_RUN=1 run write_sddm_conf
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}

@test "08_greetd sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/08_greetd.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "08_greetd DRY_RUN=1 completes without sudo" {
    source "$REPO_ROOT/scripts/08_greetd.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}
