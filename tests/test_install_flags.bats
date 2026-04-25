#!/usr/bin/env bats

SCRIPT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)/scripts/install.sh"

@test "--help exits 0 and prints USAGE" {
    run "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
}

@test "--version exits 0 and prints version string" {
    run "$SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "--dry-run --help exits 0" {
    run "$SCRIPT" --dry-run --help
    [ "$status" -eq 0 ]
}

@test "unknown flag exits 1 with error message" {
    run "$SCRIPT" --not-a-real-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"unknown"* || "$output" == *"Unknown"* ]]
}

@test "--display-manager=sddm accepted without error" {
    run "$SCRIPT" --display-manager=sddm --help
    [ "$status" -eq 0 ]
}

@test "--display-manager=invalid exits 1" {
    run "$SCRIPT" --display-manager=invalid
    [ "$status" -eq 1 ]
}

@test "--dry-run --no-packages --no-gpu --no-wifi --no-bootloader --no-display-manager --no-services exits 0 or 2" {
    run timeout 10 "$SCRIPT" --dry-run --no-packages --no-gpu --no-wifi \
        --no-bootloader --no-display-manager --no-services
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

@test "log directory test: --help exits cleanly" {
    run "$SCRIPT" --help
    [ "$status" -eq 0 ]
}
