-- wired-dots — keybindings (Lua port of keybindings.conf)
-- All volume binds call wpctl directly. No wrapper scripts.
-- See: docs/keybindings.md for full reference.
--
-- VERIFICATION NOTE: every hl.dsp.* call below was cross-checked against
-- /usr/share/hypr/hyprland.lua (the package-shipped example) and against
-- an already-working personal port on this machine. A few dispatchers used
-- in the old keybindings.conf have NO confirmed Lua equivalent in either
-- reference (togglegroup, changegroupactive, cyclenext, resizeactive,
-- fullscreen, movetoworkspacesilent, unnamed togglespecialworkspace) —
-- those are left as commented-out TODOs rather than guessed at, since a
-- wrong hl.dsp.* name errors instead of silently no-op'ing. Needs a look
-- at the Hyprland Lua API docs (https://wiki.hypr.land/) before enabling.

local mainMod = "SUPER"

-- ── Window management ──
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("loginctl terminate-user $USER"))
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
-- TODO(unverified dispatcher): togglegroup — was: bind = $mainMod, G, togglegroup
-- TODO(unverified dispatcher): changegroupactive b/f — was: bind = $mainMod Control, H/L, changegroupactive, b/f
-- TODO(unverified dispatcher): fullscreen — was: bind = Shift, F11, fullscreen
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
-- TODO(unverified dispatcher): cyclenext — was: bind = ALT, Tab, cyclenext

-- Resize
-- TODO(unverified dispatcher): resizeactive — was: binde = $mainMod Shift, Right/Left/Up/Down, resizeactive, ±30 0 / 0 ±30

-- Move (mouse)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- ── Launchers ──
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(FILE_MANAGER or "dolphin"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(BROWSER or "brave"))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd("kitty --title sysmon -e btop"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- -b 6 forces a single row of 6 buttons — see keybindings.conf for why.
hl.bind("CONTROL + ALT + Delete", hl.dsp.exec_cmd("wlogout -b 6"))

-- Rofi
hl.bind(mainMod .. " + A",   hl.dsp.exec_cmd("pkill -x rofi || rofi -show drun"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("pkill -x rofi || rofi -show window"))
hl.bind(mainMod .. " + V",   hl.dsp.exec_cmd("pkill -x rofi || ~/.local/bin/cliphist-rofi"))

-- Waybar toggle
hl.bind("ALT_R + CONTROL_R", hl.dsp.exec_cmd("killall waybar || waybar"))

-- Notifications (swaync toggle)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

-- ── Volume — wpctl direct (no wrappers, prevents queue pileup) ──
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("F10",           hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("F12",                  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("F11",                  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"),  { locked = true, repeating = true })

-- Keyboard layout
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- ── Screenshots ──
hl.bind(mainMod .. " + P",             hl.dsp.exec_cmd("~/.local/bin/screenshot.sh region"))
hl.bind(mainMod .. " + SHIFT + P",     hl.dsp.exec_cmd("~/.local/bin/screenshot.sh window"))
hl.bind(mainMod .. " + CONTROL + P",   hl.dsp.exec_cmd("~/.local/bin/screenshot.sh monitor"))

-- ── Wallpaper ──
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd("~/.local/bin/wallpaper next"))
hl.bind(mainMod .. " + ALT + left",  hl.dsp.exec_cmd("~/.local/bin/wallpaper prev"))

-- ── Workspaces ──
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    -- TODO(unverified dispatcher): movetoworkspacesilent — was: bind = $mainMod Alt, <n>, movetoworkspacesilent, <n>
end

hl.bind(mainMod .. " + CONTROL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + left",  hl.dsp.focus({ workspace = "r-1" }))
-- TODO(unverified): workspace "empty" target — was: bind = $mainMod Control, Down, workspace, empty

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + CONTROL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + ALT + left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
-- TODO(unverified dispatcher): movetoworkspacesilent special — was: bind = $mainMod Alt, S, movetoworkspacesilent, special
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
