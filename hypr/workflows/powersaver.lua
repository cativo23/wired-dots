-- wired-dots — workflow profile: powersaver (Lua port of workflows/powersaver.conf)
-- Minimal animations, no blur.

hl.config({
    decoration = {
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    animations = {
        enabled = false,
    },
})
