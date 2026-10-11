hl.window_rule({
    name  = "float-all",
    match = { class = ".*" },

    float = true,
})

hl.window_rule({
    name  = "default-size",
    match = { class = "negative:^steam$", modal = false },

    size   = "monitor_w*0.6 monitor_h*0.7",
    center = true,
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "steam-toasts",
    match = { class = "^steam$", title = "^notificationtoasts_\\d+_desktop$" },

    move             = "monitor_w-window_w-10 monitor_h-window_h-10",
    no_initial_focus = true,
})

hl.window_rule({
    name  = "steam-big-picture",
    match = { class = "^steam$", title = "^Steam Big Picture Mode$" },

    fullscreen = true,
})

hl.window_rule({
    name  = "spotify-workspace",
    match = { class = "^[Ss]potify$" },

    workspace = "name:other",
})

hl.window_rule({
    name  = "ghostty-opacity",
    match = { class = "^com\\.mitchellh\\.ghostty(-float)?$" },

    opacity = "0.9",
})

hl.window_rule({
    name  = "ghostty-float",
    match = { class = "^com\\.mitchellh\\.ghostty-float$" },

    size   = "monitor_w*0.5 monitor_h*0.6",
    center = true,
})

hl.window_rule({
    name  = "password-managers",
    match = { class = "^(org\\.keepassxc\\.KeePassXC|org\\.gnome\\.World\\.Secrets|1[Pp]assword)$" },

    no_screen_share = true,
})

hl.window_rule({
    name  = "1password-dialogs",
    match = { class = "^1[Pp]assword$", float = true },

    center = true,
})

hl.window_rule({
    name  = "wl-mirror-capture",
    match = { class = "^at\\.yrlf\\.wl_mirror$" },

    monitor          = "desc:GSV GSV HDMI2.1",
    no_initial_focus = true,
    no_focus         = true,
})

hl.on("window.open", function(w)
    if w.class == "at.yrlf.wl_mirror" then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", window = "address:" .. w.address }))
    end
end)
