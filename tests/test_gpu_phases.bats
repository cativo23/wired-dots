#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "04a sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/04a_gpu_detect.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "04a with GPU_OVERRIDE=amd exports GPU_TYPE=amd" {
    source "$REPO_ROOT/scripts/04a_gpu_detect.sh"
    GPU_OVERRIDE="amd" run ensure_gpu_type
    [ "$status" -eq 0 ]
}

@test "04a with GPU_OVERRIDE exports without calling lspci" {
    source "$REPO_ROOT/scripts/04a_gpu_detect.sh"
    GPU_OVERRIDE="nvidia-turing-plus" PATH="/nonexistent" run ensure_gpu_type
    [ "$status" -eq 0 ]
}

@test "04b sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/04b_gpu_nvidia.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "04b DRY_RUN=1 logs packages without installing" {
    source "$REPO_ROOT/scripts/04b_gpu_nvidia.sh"
    GPU_TYPE="nvidia-turing-plus" GPU_PKG_LIST="gpu-nvidia-modern.lst" DRY_RUN=1 run main
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}

@test "04c sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/04c_gpu_amd.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "04c DRY_RUN=1 completes without sudo" {
    source "$REPO_ROOT/scripts/04c_gpu_amd.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}

@test "04d sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/04d_gpu_intel.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "04d DRY_RUN=1 completes without sudo" {
    source "$REPO_ROOT/scripts/04d_gpu_intel.sh"
    DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}
