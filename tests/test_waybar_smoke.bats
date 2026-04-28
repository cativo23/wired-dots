#!/usr/bin/env bats
# Waybar smoke test — static checks against the kind of "looks fine on CI but
# renders broken at runtime" bug that hit rc1 and rc2 (literal $XDG_CONFIG_HOME
# in includes, missing custom-module configs, empty format-icons arrays,
# {}+named-placeholder mixing, dead bin/ references). Pure jq + grep, no
# waybar required, runs in any CI image with bash + jq.

setup() {
    export REPO_ROOT="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
}

# JSONC → JSON: strip // line comments without breaking strings that contain //
_jsonc_strip() {
    sed -E 's|^[[:space:]]*//.*$||; s|[[:space:]]+//[^"]*$||' "$1"
}

# All custom-module refs in cyberdeck-nerv: top-level modules-* arrays and
# any nested group definition's "modules" array.
_custom_refs() {
    local layout="$1"
    _jsonc_strip "$layout" | jq -r '
        [
            (.["modules-left"]   // []),
            (.["modules-center"] // []),
            (.["modules-right"]  // []),
            (.. | objects | .modules? // empty)
        ]
        | flatten
        | .[]
        | select(type == "string" and startswith("custom/"))
    ' | sort -u
}

@test "every waybar/modules/*.jsonc parses as JSON" {
    local f bad=0
    for f in "$REPO_ROOT"/waybar/modules/*.jsonc; do
        if ! _jsonc_strip "$f" | jq empty 2>/dev/null; then
            echo "PARSE FAIL: $f"
            _jsonc_strip "$f" | jq empty || true
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "every waybar/layouts/*.jsonc parses as JSON" {
    local f bad=0
    for f in "$REPO_ROOT"/waybar/layouts/*.jsonc; do
        if ! _jsonc_strip "$f" | jq empty 2>/dev/null; then
            echo "PARSE FAIL: $f"
            _jsonc_strip "$f" | jq empty || true
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "waybar/includes/includes.json parses as JSON" {
    run jq empty "$REPO_ROOT/waybar/includes/includes.json"
    [ "$status" -eq 0 ]
}

@test "include paths use \$HOME/.config (not \$XDG_CONFIG_HOME)" {
    # Hyprland-launched waybar has no XDG_CONFIG_HOME — caused the rc1+rc2 bug
    # where every include silently failed and modules rendered unconfigured.
    local bad=0
    if grep -q 'XDG_CONFIG_HOME' "$REPO_ROOT/waybar/includes/includes.json"; then
        echo "FAIL: includes.json uses \$XDG_CONFIG_HOME"
        bad=1
    fi
    local f
    for f in "$REPO_ROOT"/waybar/layouts/*.jsonc; do
        if grep -q 'XDG_CONFIG_HOME' "$f"; then
            echo "FAIL: $f uses \$XDG_CONFIG_HOME"
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "every module file referenced in includes.json exists" {
    local p actual bad=0
    while IFS= read -r p; do
        [ -z "$p" ] && continue
        actual="${p//\$HOME\/.config\/waybar/$REPO_ROOT/waybar}"
        if [[ ! -f "$actual" ]]; then
            echo "MISSING: $p → $actual"
            bad=1
        fi
    done < <(jq -r '.include[]' "$REPO_ROOT/waybar/includes/includes.json")
    [ "$bad" -eq 0 ]
}

@test "no module .jsonc has an empty string in format-icons" {
    # The temperature.jsonc rc3 bug — format-icons: ["", "", ...] (glyph paste
    # got stripped) silently dropped icons in the rendered format string.
    local f bad=0
    for f in "$REPO_ROOT"/waybar/modules/*.jsonc; do
        local hits
        hits=$(_jsonc_strip "$f" | jq -r '
            [.. | objects | .["format-icons"]?]
            | map(select(type == "array"))
            | .[][]
            | select(. == "")
        ' 2>/dev/null | head -1)
        if [[ -n "$hits" ]]; then
            echo "EMPTY ICON in: $f"
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "no format string mixes {} with named placeholders" {
    # The custom/swaync rc3 bug — newer libfmt errors on `"format": "{icon} {}"`.
    # Two-stage grep is more readable than jq's regex flavor wrestling.
    local f bad=0
    for f in "$REPO_ROOT"/waybar/modules/*.jsonc; do
        local format_strings
        format_strings=$(_jsonc_strip "$f" | jq -r '
            [.. | objects | (
                .format,
                .["format-charging"],
                .["format-plugged"],
                .["format-muted"],
                .["format-bluetooth"],
                .["format-bluetooth-muted"],
                .["format-disconnected"],
                .["format-warning"],
                .["format-critical"]
            ) | select(. != null)] | .[]
        ' 2>/dev/null)
        # Bare `{}` placeholder (positional)
        local has_positional
        has_positional=$(printf '%s\n' "$format_strings" | grep -E '\{\}' || true)
        # Named placeholder like {icon}, {text}, {volume}, etc.
        local has_named
        has_named=$(printf '%s\n' "$format_strings"  | grep -E '\{[a-zA-Z][a-zA-Z0-9_-]*\}' || true)
        # Per-line check: a single format string containing BOTH is the bug
        local mixed
        mixed=$(printf '%s\n' "$format_strings" \
            | grep -E '\{\}' \
            | grep -E '\{[a-zA-Z][a-zA-Z0-9_-]*\}' || true)
        if [[ -n "$mixed" ]]; then
            echo "MIXED PLACEHOLDER in $f: $mixed"
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "every custom/* module referenced in the layout has a config" {
    local layout="$REPO_ROOT/waybar/layouts/cyberdeck-nerv.jsonc"
    local refs
    refs=$(_custom_refs "$layout")
    [ -n "$refs" ]   # sanity — layout must reference at least one custom module

    # Build a single concatenated list of every defined module key, from the
    # layout itself and every modules/*.jsonc.
    local defined
    defined=$( {
        _jsonc_strip "$layout"
        local f
        for f in "$REPO_ROOT"/waybar/modules/*.jsonc; do
            _jsonc_strip "$f"
        done
    } | jq -r '[.. | objects | keys[]?] | .[]' | sort -u)

    local missing=() ref
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        if ! grep -Fxq "$ref" <<<"$defined"; then
            missing+=("$ref")
        fi
    done <<<"$refs"

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Custom modules referenced but not defined:"
        printf '  %s\n' "${missing[@]}"
        return 1
    fi
}

@test "every bin/ script referenced in keybindings exists and is executable" {
    local bin_refs name file bad=0
    bin_refs=$(grep -oE '\$HOME/\.local/bin/[a-zA-Z0-9._-]+|~/\.local/bin/[a-zA-Z0-9._-]+' \
        "$REPO_ROOT"/hypr/keybindings.conf 2>/dev/null | sort -u)
    local ref
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        name="${ref##*/}"
        file="$REPO_ROOT/bin/$name"
        if [[ ! -f "$file" ]]; then
            echo "keybinding refs $ref but bin/$name not in repo"
            bad=1
        elif [[ ! -x "$file" ]]; then
            echo "bin/$name not executable"
            bad=1
        fi
    done <<<"$bin_refs"
    [ "$bad" -eq 0 ]
}

@test "every bash script in bin/ has valid syntax" {
    local f bad=0
    for f in "$REPO_ROOT"/bin/*; do
        [[ -f "$f" ]] || continue
        # Skip non-bash scripts (e.g. python helpers if added later)
        if head -1 "$f" | grep -qE '^#!.*\b(ba)?sh\b'; then
            if ! bash -n "$f" 2>/dev/null; then
                echo "SYNTAX FAIL: $f"
                bash -n "$f" || true
                bad=1
            fi
        fi
    done
    [ "$bad" -eq 0 ]
}
