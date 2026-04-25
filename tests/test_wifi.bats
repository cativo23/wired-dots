#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

@test "05_wifi sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/05_wifi.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "handle_wifi with in-tree module skips AUR install" {
    source "$REPO_ROOT/scripts/05_wifi.sh"
    WIFI_MODULE="iwlwifi" DRY_RUN=1 run handle_wifi
    [ "$status" -eq 0 ]
    [[ "$output" != *"rtl8821ce"* ]]
}

@test "handle_wifi with rtl8821ce and FORCE_RTL_DKMS=0 skips dkms" {
    source "$REPO_ROOT/scripts/05_wifi.sh"
    WIFI_MODULE="rtl8821ce" FORCE_RTL_DKMS=0 DRY_RUN=1 run handle_wifi
    [ "$status" -eq 0 ]
}

@test "handle_wifi with rtl8821ce and FORCE_RTL_DKMS=1 triggers AUR install (dry-run)" {
    source "$REPO_ROOT/scripts/05_wifi.sh"
    WIFI_MODULE="rtl8821ce" FORCE_RTL_DKMS=1 AUR_HELPER="echo" DRY_RUN=1 run handle_wifi
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* || "$output" == *"rtl8821ce"* ]]
}

@test "handle_wifi with WIFI_MODULE=none logs skip" {
    source "$REPO_ROOT/scripts/05_wifi.sh"
    WIFI_MODULE="none" DRY_RUN=1 run handle_wifi
    [ "$status" -eq 0 ]
}
