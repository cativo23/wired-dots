#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "02_detect.sh sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\"
        source \"$REPO_ROOT/scripts/02_detect.sh\"
    "
    [[ "$status" -eq 0 || "$status" -eq 3 ]]
}

@test "detect_phase sets CPU_VENDOR when sourced" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\"
        source \"$REPO_ROOT/scripts/global_fn.sh\"
        source \"$REPO_ROOT/scripts/02_detect.sh\" 2>/dev/null || true
        printf '%s\n' \"\${CPU_VENDOR:-unset}\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == "intel" || "$output" == "amd" || "$output" == "unknown" ]]
}

@test "print_detection_summary does not crash" {
    source "$REPO_ROOT/scripts/02_detect.sh" 2>/dev/null || true
    run print_detection_summary
    [ "$status" -eq 0 ]
}

@test "detect phase exports HAS_BATTERY" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\"
        source \"$REPO_ROOT/scripts/global_fn.sh\"
        source \"$REPO_ROOT/scripts/02_detect.sh\" 2>/dev/null || true
        printf '%s\n' \"\${HAS_BATTERY:-unset}\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == "0" || "$output" == "1" ]]
}
