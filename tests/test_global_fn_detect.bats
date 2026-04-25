#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "detect_gpu returns nvidia-turing-plus for RTX 3080 (10de:2206)" {
    export LSPCI_OVERRIDE="10de:2206"
    run detect_gpu
    [ "$status" -eq 0 ]
    [[ "$output" == *"nvidia-turing-plus"* ]]
}

@test "detect_gpu returns amd-rdna for RX 5700 XT (1002:731f)" {
    export LSPCI_OVERRIDE="1002:731f"
    run detect_gpu
    [ "$status" -eq 0 ]
    [[ "$output" == *"amd-rdna"* ]]
}

@test "detect_gpu returns intel-xe-arc for Intel Iris Xe (8086:9a49)" {
    export LSPCI_OVERRIDE="8086:9a49"
    run detect_gpu
    [ "$status" -eq 0 ]
    [[ "$output" == *"intel-xe-arc"* ]]
}

@test "detect_gpu returns unknown for unrecognized PCI ID" {
    export LSPCI_OVERRIDE="ffff:0001"
    run detect_gpu
    [ "$status" -eq 3 ]
    [[ "$output" == *"unknown"* ]]
}

@test "detect_gpu respects GPU_OVERRIDE env var" {
    GPU_OVERRIDE="amd" run detect_gpu
    [ "$status" -eq 0 ]
    [[ "$output" == *"amd"* ]]
}
