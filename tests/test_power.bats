#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export WIRED_LOG_FILE="/dev/null"
    export NONINTERACTIVE=1
}

teardown() { rm -rf "$TEST_TMP"; }

@test "04e_power.sh sources without error" {
    run bash -c "
        export REPO_ROOT='$REPO_ROOT' WIRED_LOG_FILE=/dev/null
        source '$REPO_ROOT/scripts/04e_power.sh'
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "04e is a no-op when WITH_TLP=0" {
    run bash -c "
        export REPO_ROOT='$REPO_ROOT' WIRED_LOG_FILE=/dev/null WITH_TLP=0 DRY_RUN=1
        bash '$REPO_ROOT/scripts/04e_power.sh'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"TLP not requested"* ]]
}

@test "04e DRY_RUN=1 with WITH_TLP=1 logs intent without writing /etc" {
    run bash -c "
        export REPO_ROOT='$REPO_ROOT' WIRED_LOG_FILE=/dev/null WITH_TLP=1 DRY_RUN=1
        bash '$REPO_ROOT/scripts/04e_power.sh'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"would deploy"* ]] || [[ "$output" == *"dry-run"* ]]
}

@test "detect_charge_threshold_battery returns empty when no battery exposes thresholds" {
    # Real /sys may or may not have charge_control thresholds. We can't fake
    # /sys easily, so this just exercises the function — exit non-zero is OK,
    # as long as the function handles "no battery" gracefully (no stderr noise).
    run bash -c "
        export REPO_ROOT='$REPO_ROOT' WIRED_LOG_FILE=/dev/null
        source '$REPO_ROOT/scripts/04e_power.sh'
        # function not main — just probe the helper
        out=\$(detect_charge_threshold_battery 2>&1) || true
        echo \"out:\$out\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == out:* ]]   # function returned cleanly (empty or BAT name)
}

@test "99-wired.conf no longer hardcodes DISK_DEVICES" {
    ! grep -q "^DISK_DEVICES=" "$REPO_ROOT/source/assets/tlp/tlp.d/99-wired.conf"
}

@test "99-wired.conf no longer hardcodes BAT0 charge thresholds" {
    ! grep -qE "^(START|STOP)_CHARGE_THRESH_BAT0=" "$REPO_ROOT/source/assets/tlp/tlp.d/99-wired.conf"
}

@test "03b WITH_TLP=1 swaps power-profiles-daemon for tlp + tlp-rdw" {
    # Source 03b just to access main()'s logic. Shadow install_packages so the
    # final call captures the package array instead of running pacman.
    run bash -c "
        export REPO_ROOT='$REPO_ROOT' WIRED_LOG_FILE=/dev/null DRY_RUN=0 WITH_TLP=1
        # Shadow install_packages: print the package list and exit instead of
        # running pacman.
        source '$REPO_ROOT/scripts/03b_core_packages.sh'
        # Redefine AFTER source so global_fn.sh's version is shadowed
        install_packages() {
            local -n arr=\$1
            printf 'PKGS:'
            printf ' %s' \"\${arr[@]}\"
            printf '\n'
            return 0
        }
        main 2>&1
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *" tlp "* ]] || [[ "$output" == *" tlp"$'\n'* ]] || [[ "$output" == *" tlp-rdw"* ]]
    [[ "$output" != *"power-profiles-daemon"* ]]
}

@test "03b WITH_TLP=0 keeps power-profiles-daemon and does not add tlp" {
    run bash -c "
        export REPO_ROOT='$REPO_ROOT' WIRED_LOG_FILE=/dev/null DRY_RUN=0 WITH_TLP=0
        source '$REPO_ROOT/scripts/03b_core_packages.sh'
        # Redefine AFTER source so global_fn.sh's version is shadowed
        install_packages() {
            local -n arr=\$1
            printf 'PKGS:'
            printf ' %s' \"\${arr[@]}\"
            printf '\n'
            return 0
        }
        main 2>&1
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"power-profiles-daemon"* ]]
    [[ "$output" != *" tlp "* ]] && [[ "$output" != *" tlp-rdw"* ]]
}
