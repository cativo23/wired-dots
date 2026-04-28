#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export TEST_TMP="$(mktemp -d)"
    export HOME="$TEST_TMP"
    export WIRED_LOG_FILE="/dev/null"
    export NONINTERACTIVE=1
    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/wired-dots/backups"
}

teardown() { rm -rf "$TEST_TMP"; }

# Helper: source uninstall.sh's functions without running main.
_source_uninstall() {
    # Mark as sourced so the trailing `if [[ BASH_SOURCE == 0 ]]` block skips main.
    set +e
    # shellcheck disable=SC1090
    BASH_SOURCE_OVERRIDE=1 source "$REPO_ROOT/uninstall.sh"
    set -e
}

@test "uninstall.sh has executable bit" {
    [ -x "$REPO_ROOT/uninstall.sh" ]
}

@test "uninstall.sh syntax check" {
    run bash -n "$REPO_ROOT/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "remove_symlinks_from removes symlinks only" {
    _source_uninstall
    ln -s /tmp "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/realdir"  # decoy real dir, must survive

    DRY_RUN=0 run remove_symlinks_from "configs" "$HOME/.config" hypr realdir
    [ "$status" -eq 0 ]
    [ ! -e "$HOME/.config/hypr" ]
    [ -d "$HOME/.config/realdir" ]
}

@test "remove_symlinks_from DRY_RUN=1 leaves symlinks intact" {
    _source_uninstall
    ln -s /tmp "$HOME/.config/hypr"
    DRY_RUN=1 run remove_symlinks_from "configs" "$HOME/.config" hypr
    [ "$status" -eq 0 ]
    [ -L "$HOME/.config/hypr" ]
}

@test "remove_runtime_artifacts removes wired-dots config + waybar share dirs" {
    _source_uninstall
    mkdir -p "$HOME/.config/wired-dots/wallpapers"
    mkdir -p "$HOME/.local/share/waybar/styles"
    : > "$HOME/.config/wired-dots/wallpapers/x.png"
    : > "$HOME/.local/share/waybar/styles/x.css"

    DRY_RUN=0 run remove_runtime_artifacts
    [ "$status" -eq 0 ]
    [ ! -e "$HOME/.config/wired-dots" ]
    [ ! -e "$HOME/.local/share/waybar" ]
}

@test "restore_latest_backup picks newest timestamp dir" {
    _source_uninstall
    local root="$HOME/.local/share/wired-dots/backups"
    mkdir -p "$root/20250101T000000/hypr" "$root/20260427T120000/hypr"
    : > "$root/20250101T000000/hypr/old"
    : > "$root/20260427T120000/hypr/new"

    DRY_RUN=0 run restore_latest_backup
    [ "$status" -eq 0 ]
    [ -f "$HOME/.config/hypr/new" ]
    [ ! -f "$HOME/.config/hypr/old" ]
}

@test "restore_latest_backup skips when no backups exist" {
    _source_uninstall
    rm -rf "$HOME/.local/share/wired-dots/backups"
    DRY_RUN=0 run restore_latest_backup
    [ "$status" -eq 0 ]
    [[ "$output" == *"no wired-dots backups found"* ]]
}

@test "restore_latest_backup DRY_RUN=1 makes no changes" {
    _source_uninstall
    local root="$HOME/.local/share/wired-dots/backups"
    mkdir -p "$root/20260427T120000/hypr"
    : > "$root/20260427T120000/hypr/file"
    DRY_RUN=1 run restore_latest_backup
    [ "$status" -eq 0 ]
    [ ! -e "$HOME/.config/hypr" ]
}

@test "main flow removes 18 config symlinks and 4 bin symlinks (DRY_RUN=1)" {
    # Pre-stage symlinks for every CONFIG_DIRS + BIN_FILES entry.
    local dirs=(hypr waybar kitty starship fastfetch zsh swaync rofi wlogout
                bat gtk-3.0 gtk-4.0 qt5ct qt6ct Kvantum xdg-desktop-portal
                wireplumber git)
    local bins=(cliphist-rofi power-profile-switch screenshot.sh wallpaper)
    for d in "${dirs[@]}"; do ln -s /tmp "$HOME/.config/$d"; done
    for b in "${bins[@]}"; do ln -s /tmp "$HOME/.local/bin/$b"; done

    DRY_RUN=1 run bash "$REPO_ROOT/uninstall.sh"
    [ "$status" -eq 0 ]
    # All symlinks survive because DRY_RUN=1.
    for d in "${dirs[@]}"; do [ -L "$HOME/.config/$d" ]; done
    for b in "${bins[@]}"; do [ -L "$HOME/.local/bin/$b" ]; done
    # Output mentions all unlink intentions.
    [[ "$output" == *"would unlink"* ]]
}

@test "main flow removes 18 config symlinks and 4 bin symlinks (real run)" {
    local dirs=(hypr waybar kitty starship fastfetch zsh swaync rofi wlogout
                bat gtk-3.0 gtk-4.0 qt5ct qt6ct Kvantum xdg-desktop-portal
                wireplumber git)
    local bins=(cliphist-rofi power-profile-switch screenshot.sh wallpaper)
    for d in "${dirs[@]}"; do ln -s /tmp "$HOME/.config/$d"; done
    for b in "${bins[@]}"; do ln -s /tmp "$HOME/.local/bin/$b"; done

    run bash "$REPO_ROOT/uninstall.sh"
    [ "$status" -eq 0 ]
    for d in "${dirs[@]}"; do [ ! -e "$HOME/.config/$d" ]; done
    for b in "${bins[@]}"; do [ ! -e "$HOME/.local/bin/$b" ]; done
    [[ "$output" == *"uninstall complete"* ]]
}

@test "main flow exits 0 when nothing to uninstall" {
    run bash "$REPO_ROOT/uninstall.sh"
    [ "$status" -eq 0 ]
}
