-- wired-dots — workflow profile: gaming (Lua port of workflows/gaming.conf)
-- Disable blur/shadows for max FPS, enable VRR.

hl.config({
    decoration = {
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    misc = {
        no_vd_cursor_hack = true,
    },
    general = {
        allow_tearing = true,
    },
})
