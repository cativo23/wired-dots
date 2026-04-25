#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "03b sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/03b_core_packages.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "03b DRY_RUN=1 lists packages without installing" {
    source "$REPO_ROOT/scripts/03b_core_packages.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}

@test "03c sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/03c_audio.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "03d sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/03d_fonts.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "03e sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/03e_bluetooth.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "03f sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/03f_aur_packages.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "read_pkg_list strips comments and blank lines" {
    source "$REPO_ROOT/scripts/03b_core_packages.sh"
    local result
    result="$(read_pkg_list "$REPO_ROOT/source/packages/core.lst")"
    [[ "$result" == *"hyprland"* ]]
    [[ "$result" != *"# "* ]]
}

@test "03e DRY_RUN=1 skips service enable" {
    source "$REPO_ROOT/scripts/03e_bluetooth.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}

@test "03f DRY_RUN=1 runs without AUR helper present" {
    source "$REPO_ROOT/scripts/03f_aur_packages.sh"
    AUR_HELPER="echo" DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}
