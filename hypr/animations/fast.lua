-- wired-dots — animation profile: fast (Lua port of animations/fast.conf)

hl.curve("snap", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",    enabled = true, speed = 2, bezier = "snap", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "snap", style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snap", style = "slide" })
