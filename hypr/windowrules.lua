-- wired-dots — window rules (Lua port of windowrules.conf)
-- Float system dialogs and configuration tools.

hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(pavucontrol|pwvucontrol)$" },
    float = true,
})

hl.window_rule({
    name  = "float-net-config",
    match = { class = "^(nm-connection-editor|blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name  = "float-calc",
    match = { class = "^(org\\.gnome\\.Calculator)$" },
    float = true,
})

hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
})

hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = "^(Open File|Save As)$" },
    float = true,
})

hl.window_rule({
    name  = "float-portal",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
})

hl.window_rule({
    name   = "sysmon-dropdown",
    match  = { title = "^(sysmon)$" },
    float  = true,
    size   = "1200 700",
    center = true,
})
