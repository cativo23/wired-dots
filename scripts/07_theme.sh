#!/usr/bin/env bash
# wired-dots — phase 07: GTK theme + cursor
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
export REPO_ROOT SCRIPTS_DIR
# shellcheck source=scripts/global_fn.sh
source "$SCRIPTS_DIR/global_fn.sh"

GTK_THEME="Tokyonight-GTK-BL"
ICON_THEME="Tela-circle-dracula"
CURSOR_THEME="phinger-cursors-dark"
CURSOR_SIZE=24
FONT_NAME="Red Hat Display 11"

apply_gtk_theme() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would set GTK theme=$GTK_THEME icons=$ICON_THEME font=$FONT_NAME"
        return 0
    fi

    if ! command -v gsettings &>/dev/null; then
        log_warn "gsettings not found — GTK theme not applied via dconf. Config file fallback active."
        return 0
    fi

    gsettings set org.gnome.desktop.interface gtk-theme       "$GTK_THEME"  2>/dev/null && log_ok "GTK theme: $GTK_THEME"    || log_warn "could not set gtk-theme"
    gsettings set org.gnome.desktop.interface icon-theme      "$ICON_THEME" 2>/dev/null && log_ok "icon theme: $ICON_THEME"   || log_warn "could not set icon-theme"
    gsettings set org.gnome.desktop.interface font-name       "$FONT_NAME"  2>/dev/null && log_ok "font: $FONT_NAME"          || log_warn "could not set font"
    gsettings set org.gnome.desktop.interface color-scheme    "prefer-dark" 2>/dev/null && log_ok "color-scheme: prefer-dark" || log_warn "could not set color-scheme"
}

apply_cursor_theme() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would set cursor theme=$CURSOR_THEME size=$CURSOR_SIZE"
        return 0
    fi

    if ! command -v gsettings &>/dev/null; then
        log_warn "gsettings not found — cursor theme not applied via dconf"
        return 0
    fi

    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null && log_ok "cursor: $CURSOR_THEME"    || log_warn "could not set cursor-theme"
    gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"  2>/dev/null && log_ok "cursor size: $CURSOR_SIZE" || log_warn "could not set cursor-size"
}

write_gtk3_ini() {
    log_skip "gtk-3.0/settings.ini handled by 06_symlinks.sh"
}

main() {
    log_step "07" "theme"
    apply_gtk_theme
    apply_cursor_theme
    write_gtk3_ini
    log_ok "theme complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main; fi
