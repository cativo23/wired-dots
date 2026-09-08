-- wired-dots — animation profile: smooth (Lua port of animations/smooth.conf)

hl.curve("easeOut", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.curve("easeIn",  { type = "bezier", points = { {0.7, 0}, {0.84, 0} } })
hl.curve("linear",  { type = "bezier", points = { {0, 0}, {1, 1} } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4,  bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3,  bezier = "easeIn",  style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4,  bezier = "easeOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,  bezier = "easeOut", style = "slide" })
