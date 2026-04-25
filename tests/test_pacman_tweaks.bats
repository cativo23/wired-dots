#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

teardown() { rm -rf "$TEST_TMP"; }

@test "03a sources without running main" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\"
        export WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/03a_pacman_tweaks.sh\"
        echo 'sourced ok'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced ok"* ]]
}

@test "sentinel_check returns 2 (never applied) on fresh file" {
    local fake_conf="$TEST_TMP/pacman.conf"
    printf '[options]\n' > "$fake_conf"
    run sentinel_check "$fake_conf"
    [ "$status" -eq 2 ]
}

@test "sentinel_check returns 0 after apply_patch writes sentinel" {
    local fake_conf="$TEST_TMP/pacman.conf"
    printf '[options]\n' > "$fake_conf"
    sha256sum "$fake_conf" | awk '{print $1}' > "${fake_conf}.wired.bkp"
    run sentinel_check "$fake_conf"
    [ "$status" -eq 0 ]
}

@test "sentinel_check returns 1 (drifted) when file changed after patch" {
    local fake_conf="$TEST_TMP/pacman.conf"
    printf '[options]\n' > "$fake_conf"
    sha256sum "$fake_conf" | awk '{print $1}' > "${fake_conf}.wired.bkp"
    printf 'Color\n' >> "$fake_conf"
    run sentinel_check "$fake_conf"
    [ "$status" -eq 1 ]
}

@test "DRY_RUN=1 skips pacman_conf patching without sudo" {
    source "$REPO_ROOT/scripts/03a_pacman_tweaks.sh"
    DRY_RUN=1 GPU_TYPE="unknown" run main
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}
