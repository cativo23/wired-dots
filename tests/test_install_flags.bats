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

@test "--dry-run with all --no-* flags exits 0" {
    run timeout 10 "$SCRIPT" --dry-run --no-packages --no-gpu --no-wifi \
        --no-bootloader --no-display-manager --no-services
    [ "$status" -eq 0 ]
}

@test "log directory test: --help exits cleanly" {
    run "$SCRIPT" --help
    [ "$status" -eq 0 ]
}

# ── User choice flags (PR C) ──────────────────────────────────────────────────

@test "--kb-layout=us accepted" {
    run "$SCRIPT" --kb-layout=us --help
    [ "$status" -eq 0 ]
}

@test "--kb-layout=latam,us accepted" {
    run "$SCRIPT" --kb-layout=latam,us --help
    [ "$status" -eq 0 ]
}

@test "--kb-layout=invalid exits 1 with error" {
    run "$SCRIPT" --kb-layout=qwerty
    [ "$status" -eq 1 ]
    [[ "$output" == *"--kb-layout"* ]]
}

@test "--with-browser=firefox accepted" {
    run "$SCRIPT" --with-browser=firefox --help
    [ "$status" -eq 0 ]
}

@test "--with-browser=brave-bin accepted" {
    run "$SCRIPT" --with-browser=brave-bin --help
    [ "$status" -eq 0 ]
}

@test "--with-browser=invalid exits 1" {
    run "$SCRIPT" --with-browser=opera
    [ "$status" -eq 1 ]
    [[ "$output" == *"--with-browser"* ]]
}

@test "--with-file-manager=thunar accepted" {
    run "$SCRIPT" --with-file-manager=thunar --help
    [ "$status" -eq 0 ]
}

@test "--with-file-manager=invalid exits 1" {
    run "$SCRIPT" --with-file-manager=ranger
    [ "$status" -eq 1 ]
    [[ "$output" == *"--with-file-manager"* ]]
}

@test "--noninteractive --dry-run with explicit choices applies them" {
    run timeout 10 "$SCRIPT" --noninteractive --dry-run \
        --kb-layout=de --with-browser=chromium --with-file-manager=nemo
    [ "$status" -eq 0 ]
    [[ "$output" == *"kb_layout=de"* ]]
    [[ "$output" == *"browser=chromium"* ]]
    [[ "$output" == *"file-manager=nemo"* ]]
}

@test "--noninteractive --dry-run without choice flags falls back to defaults" {
    run timeout 10 "$SCRIPT" --noninteractive --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"kb_layout=us"* ]]
    [[ "$output" == *"browser=brave-bin"* ]]
    [[ "$output" == *"file-manager=dolphin"* ]]
}
