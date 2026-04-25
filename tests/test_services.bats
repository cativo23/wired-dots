#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "10a sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/10a_system_services.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "10a DRY_RUN=1 completes without systemctl" {
    source "$REPO_ROOT/scripts/10a_system_services.sh"
    DRY_RUN=1 DISPLAY_MANAGER="sddm" run main
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}

@test "10b sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/10b_xdg_portal_restart.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "10b DRY_RUN=1 logs portals without killing processes" {
    source "$REPO_ROOT/scripts/10b_xdg_portal_restart.sh"
    DRY_RUN=1 run restart_xdg_portals
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}

@test "10c sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/10c_verification.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "10c check_package returns 0 for installed bash" {
    source "$REPO_ROOT/scripts/10c_verification.sh"
    run check_package "bash"
    [ "$status" -eq 0 ]
}

@test "10c check_package returns 1 for nonexistent-pkg-xyz" {
    source "$REPO_ROOT/scripts/10c_verification.sh"
    run check_package "nonexistent-pkg-xyz-wired"
    [ "$status" -eq 1 ]
}

@test "10c DRY_RUN=1 main completes and prints summary" {
    source "$REPO_ROOT/scripts/10c_verification.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}
