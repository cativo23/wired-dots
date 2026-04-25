#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    source "$REPO_ROOT/scripts/global_fn.sh"
    # Suppress log file writes during tests
    export WIRED_LOG_FILE="/dev/null"
}

@test "log_ok outputs green checkmark and message" {
    run log_ok "install complete"
    [ "$status" -eq 0 ]
    [[ "$output" == *"✓"* ]]
    [[ "$output" == *"install complete"* ]]
}

@test "log_warn outputs yellow warning and message" {
    run log_warn "disk space low"
    [ "$status" -eq 0 ]
    [[ "$output" == *"⚠"* ]]
    [[ "$output" == *"disk space low"* ]]
}

@test "log_err outputs red error and message" {
    run log_err "no internet"
    [ "$status" -eq 0 ]
    [[ "$output" == *"✗"* ]]
    [[ "$output" == *"no internet"* ]]
}

@test "log_step outputs numbered step with arrow" {
    run log_step "3" "installing packages"
    [ "$status" -eq 0 ]
    [[ "$output" == *"▶"* ]]
    [[ "$output" == *"3"* ]]
    [[ "$output" == *"installing packages"* ]]
}

@test "log_skip outputs muted skip marker" {
    run log_skip "package already installed"
    [ "$status" -eq 0 ]
    [[ "$output" == *"○"* ]]
    [[ "$output" == *"package already installed"* ]]
}

@test "log_info outputs blue info marker" {
    run log_info "detected NVIDIA GPU"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ℹ"* ]]
    [[ "$output" == *"detected NVIDIA GPU"* ]]
}

@test "draw_box renders title and content" {
    run draw_box "core packages" "✓ 52 pacman packages" "3m 14s"
    [ "$status" -eq 0 ]
    [[ "$output" == *"╭"* ]]
    [[ "$output" == *"core packages"* ]]
    [[ "$output" == *"52 pacman packages"* ]]
    [[ "$output" == *"3m 14s"* ]]
    [[ "$output" == *"╰"* ]]
}

@test "draw_box renders without duration when empty" {
    run draw_box "detect" "✓ GPU: nvidia-turing-plus" ""
    [ "$status" -eq 0 ]
    [[ "$output" == *"╭"* ]]
    [[ "$output" == *"GPU: nvidia-turing-plus"* ]]
}

@test "spinner does not crash on short-lived process" {
    sleep 0.1 &
    local pid=$!
    run spinner "$pid" "testing spinner"
    [ "$status" -eq 0 ]
}
