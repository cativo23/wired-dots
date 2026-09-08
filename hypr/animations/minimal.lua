-- wired-dots — animation profile: minimal (Lua port of animations/minimal.conf)

hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",    enabled = true, speed = 2, bezier = "linear", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "linear" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "linear" })
