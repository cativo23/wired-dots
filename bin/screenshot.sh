#!/usr/bin/env bash
# wired-dots — screenshot helper
# Wraps hyprshot; falls back to grim+slurp if hyprshot unavailable.
# Usage: screenshot.sh region|window|monitor|all
set -euo pipefail

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/screenshots"
mkdir -p "$SAVE_DIR"

FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
DEST="$SAVE_DIR/$FILENAME"

capture() {
    local mode="$1"
    if command -v hyprshot >/dev/null 2>&1; then
        case "$mode" in
            region)  hyprshot -m region  --output-folder "$SAVE_DIR" --filename "$FILENAME" ;;
            window)  hyprshot -m window  --output-folder "$SAVE_DIR" --filename "$FILENAME" ;;
            monitor) hyprshot -m output  --output-folder "$SAVE_DIR" --filename "$FILENAME" ;;
            all)     hyprshot -m output  --output-folder "$SAVE_DIR" --filename "$FILENAME" ;;
        esac
    else
        # Fallback: grim + slurp (official repos)
        case "$mode" in
            region)  grim -g "$(slurp)" "$DEST" ;;
            window)  grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$DEST" ;;
            monitor) grim "$DEST" ;;
            all)     grim "$DEST" ;;
        esac
    fi
    # Open in satty for annotation if available
    if command -v satty >/dev/null 2>&1 && [ -f "$DEST" ]; then
        satty --filename "$DEST" &
    fi
}

mode="${1:-region}"
case "$mode" in
    region|window|monitor|all) capture "$mode" ;;
    *) echo "Usage: $0 region|window|monitor|all" >&2; exit 1 ;;
esac
