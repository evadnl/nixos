local mainMod = "SUPER"
local hyper   = "CTRL + ALT + SHIFT + SUPER"
local ipc     = "noctalia msg "
local browser = "gtk-launch $(xdg-settings get default-web-browser)"

local gapOut = 8
local gapIn  = 4

local function usableArea(m)
    local r = m.reserved
    return {
        x = m.x + r.left + gapOut,
        y = m.y + r.top + gapOut,
        w = m.width / m.scale - r.left - r.right - 2 * gapOut,
        h = m.height / m.scale - r.top - r.bottom - 2 * gapOut,
    }
end

local function prepare(w)
    if w.fullscreen > 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = w.fullscreen == 1 and "maximized" or "fullscreen", action = "unset" }))
    end
    if not w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    end
end

local function place(fx, fw, fy, fh)
    fy, fh = fy or 0, fh or 1
    return function()
        local w = hl.get_active_window()
        if not w or not w.monitor then return end
        prepare(w)

        local a = usableArea(w.monitor)
        local x, y = a.x + a.w * fx, a.y + a.h * fy
        local width, height = a.w * fw, a.h * fh

        if fx > 0 then x, width = x + gapIn, width - gapIn end
        if fx + fw < 1 then width = width - gapIn end
        if fy > 0 then y, height = y + gapIn, height - gapIn end
        if fy + fh < 1 then height = height - gapIn end

        hl.dispatch(hl.dsp.window.resize({ x = math.floor(width), y = math.floor(height) }))
        hl.dispatch(hl.dsp.window.move({ x = math.floor(x), y = math.floor(y) }))
    end
end

local function grow(d)
    return function()
        local w = hl.get_active_window()
        if not w then return end
        prepare(w)
        hl.dispatch(hl.dsp.window.resize({ x = 2 * d, y = 2 * d, relative = true }))
        hl.dispatch(hl.dsp.window.move({ x = -d, y = -d, relative = true }))
    end
end

local function cycleApp()
    local active = hl.get_active_window()
    if not active or not active.workspace then return end

    local same = {}
    for _, w in ipairs(hl.get_windows()) do
        if w.mapped and w.class == active.class and w.workspace and w.workspace.id == active.workspace.id then
            table.insert(same, w)
        end
    end
    if #same < 2 then return end
    table.sort(same, function(a, b) return a.stable_id < b.stable_id end)

    for i, w in ipairs(same) do
        if w.address == active.address then
            local nextWindow = same[i % #same + 1]
            hl.dispatch(hl.dsp.focus({ window = "address:" .. nextWindow.address }))
            hl.dispatch(hl.dsp.window.bring_to_top())
            return
        end
    end
end

hl.bind(hyper .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(hyper .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(hyper .. " + C",      hl.dsp.exec_cmd("code"))

hl.bind(hyper .. " + W", hl.dsp.submap("snap"))
hl.bind("W", hl.dsp.submap("reset"), { release = true, ignore_mods = true, non_consuming = true, transparent = true })

hl.define_submap("snap", function()
    hl.bind(hyper .. " + H",      place(0, 0.5))
    hl.bind(hyper .. " + L",      place(0.5, 0.5))
    hl.bind(hyper .. " + J",      place(0.25, 0.5))
    hl.bind(hyper .. " + Return", place(0, 1))
    hl.bind(hyper .. " + Space",  place(0.05, 0.9, 0.05, 0.9))
    hl.bind(hyper .. " + K",      place(0.05, 0.9, 0.05, 0.9))
    hl.bind(hyper .. " + N",      place(0, 0.75))
    hl.bind(hyper .. " + Period", place(0.25, 0.75))
    hl.bind(hyper .. " + M",      place(0, 2 / 3))
    hl.bind(hyper .. " + Comma",  place(1 / 3, 2 / 3))
    hl.bind(hyper .. " + Y",      place(0, 1 / 3))
    hl.bind(hyper .. " + O",      place(2 / 3, 1 / 3))
    hl.bind(hyper .. " + U",      place(0, 0.25))
    hl.bind(hyper .. " + I",      place(0.75, 0.25))
    hl.bind(hyper .. " + Equal",  grow(30),  { repeating = true })
    hl.bind(hyper .. " + Minus",  grow(-30), { repeating = true })
    hl.bind(hyper .. " + P",      cycleApp)
    hl.bind(hyper .. " + up",     hl.dsp.window.move({ monitor = "u" }))
    hl.bind(hyper .. " + down",   hl.dsp.window.move({ monitor = "d" }))

    hl.bind("W",      hl.dsp.submap("reset"), { release = true, ignore_mods = true })
    hl.bind("Escape", hl.dsp.submap("reset"), { ignore_mods = true })
end)

hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.exec_cmd("ghostty --class=com.mitchellh.ghostty-float"))
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + ALT + L",       hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind(mainMod .. " + ALT + S",       hl.dsp.exec_cmd("pkill orca || exec orca"), { locked = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                              { locked = true })
hl.bind("XF86AudioStop",        hl.dsp.exec_cmd("playerctl stop"),                                    { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                                { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                    { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl --class=backlight set +10%"),         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --class=backlight set 10%-"),         { locked = true, repeating = true })

hl.bind(mainMod .. " + W", hl.dsp.window.close())

local directions = { H = "left", J = "down", K = "up", L = "right", left = "left", down = "down", up = "up", right = "right" }
local monitorDirections = { left = "l", down = "d", up = "u", right = "r" }
for key, dir in pairs(directions) do
    hl.bind(mainMod .. " + " .. key,                 hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + CTRL + " .. key,          hl.dsp.window.move({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key,         hl.dsp.focus({ monitor = monitorDirections[dir] }))
    hl.bind(mainMod .. " + SHIFT + CTRL + " .. key,  hl.dsp.window.move({ monitor = monitorDirections[dir] }))
end

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. i,   hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + U",                hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + I",                hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + Page_Down",        hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + Page_Up",          hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + U",         hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + I",         hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + Page_Down", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + Page_Up",   hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + mouse_down",       hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",         hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + C",         hl.dsp.window.center())

local function cycle(next)
    return function()
        hl.dispatch(hl.dsp.window.cycle_next({ next = next }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end

hl.bind("ALT + Tab",         cycle(true))
hl.bind("ALT + SHIFT + Tab", cycle(false))

hl.bind(mainMod .. " + Minus",         hl.dsp.window.resize({ x = -100, y = 0, relative = true }),   { repeating = true })
hl.bind(mainMod .. " + Equal",         hl.dsp.window.resize({ x = 100, y = 0, relative = true }),    { repeating = true })
hl.bind(mainMod .. " + SHIFT + Minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }),   { repeating = true })
hl.bind(mainMod .. " + SHIFT + Equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }),    { repeating = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print",        hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("CTRL + ALT + Delete",     hl.dsp.exec_cmd("uwsm stop"))
