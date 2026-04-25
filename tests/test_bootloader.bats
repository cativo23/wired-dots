#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export WIRED_LOG_FILE="/dev/null"
    source "$REPO_ROOT/scripts/global_fn.sh"
}

teardown() { rm -rf "$TEST_TMP"; }

@test "09_bootloader sources without error" {
    run bash -c "
        export REPO_ROOT=\"$REPO_ROOT\" WIRED_LOG_FILE=/dev/null
        source \"$REPO_ROOT/scripts/09_bootloader.sh\"
        echo sourced
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]]
}

@test "patch_grub_cmdline DRY_RUN=1 logs without modifying file" {
    source "$REPO_ROOT/scripts/09_bootloader.sh"
    local fake_grub="$TEST_TMP/grub"
    printf 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"\n' > "$fake_grub"
    GRUB_DEFAULT_FILE="$fake_grub" GPU_CMDLINE="nvidia_drm.modeset=1" DRY_RUN=1 run patch_grub_cmdline
    [ "$status" -eq 0 ]
    grep -q 'quiet splash"' "$fake_grub"
    [[ "$output" != *"nvidia_drm"* || "$output" == *"dry-run"* ]]
}

@test "patch_grub_cmdline skips when params already present" {
    source "$REPO_ROOT/scripts/09_bootloader.sh"
    local fake_grub="$TEST_TMP/grub"
    printf 'GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia_drm.modeset=1"\n' > "$fake_grub"
    GRUB_DEFAULT_FILE="$fake_grub" GPU_CMDLINE="nvidia_drm.modeset=1" DRY_RUN=0 run patch_grub_cmdline
    [ "$status" -eq 0 ]
    [[ "$output" == *"already"* || "$output" == *"skip"* ]]
}

@test "patch_grub_cmdline skips when GPU_CMDLINE is empty" {
    source "$REPO_ROOT/scripts/09_bootloader.sh"
    local fake_grub="$TEST_TMP/grub"
    printf 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"\n' > "$fake_grub"
    GRUB_DEFAULT_FILE="$fake_grub" GPU_CMDLINE="" DRY_RUN=0 run patch_grub_cmdline
    [ "$status" -eq 0 ]
}

@test "main DRY_RUN=1 with BOOTLOADER=grub logs without sudo" {
    source "$REPO_ROOT/scripts/09_bootloader.sh"
    BOOTLOADER="grub" GPU_CMDLINE="nvidia_drm.modeset=1" DRY_RUN=1 run main
    [ "$status" -eq 0 ]
}

@test "main with BOOTLOADER=systemd-boot skips GRUB patching" {
    source "$REPO_ROOT/scripts/09_bootloader.sh"
    BOOTLOADER="systemd-boot" GPU_CMDLINE="nvidia_drm.modeset=1" DRY_RUN=1 run main
    [ "$status" -eq 0 ]
    [[ "$output" == *"systemd-boot"* || "$output" == *"skip"* ]]
}
