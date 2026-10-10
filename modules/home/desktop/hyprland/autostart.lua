local mainMonitor = "desc:ASUSTek COMPUTER INC PG34WCDN W4LMAS016832"

local function focusMain()
    local m = hl.get_monitor(mainMonitor)
    if not m then return end
    hl.dispatch(hl.dsp.cursor.move({ x = m.x + m.width / m.scale / 2, y = m.y + m.height / m.scale / 2 }))
    hl.dispatch(hl.dsp.focus({ monitor = mainMonitor }))
end

hl.on("hyprland.start", function()
    focusMain()
    hl.timer(focusMain, { timeout = 1000, type = "oneshot" })

    hl.exec_cmd("noctalia")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("vesktop")
    hl.exec_cmd("1password --silent")
    hl.exec_cmd("steam -silent -pipewire")
end)
