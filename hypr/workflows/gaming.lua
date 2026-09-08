-- wired-dots — workflow profile: gaming (Lua port of workflows/gaming.conf)
-- Disable blur/shadows for max FPS, enable VRR.

-- misc:no_vd_cursor_hack from the original workflows/gaming.conf does not
-- exist in this Hyprland build (verified against /usr/bin/Hyprland's own
-- string table — not present in any form). This is a pre-existing bug in
-- the shipped v1.0.1 .conf, not something introduced by this port; dropped
-- here rather than guessed at, upstream gaming.conf needs the same fix.
hl.config({
    decoration = {
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    general = {
        allow_tearing = true,
    },
})
