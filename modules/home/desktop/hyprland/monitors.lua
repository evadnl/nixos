hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR 103NTBK9D077",
    mode     = "3440x1440@160",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "desc:ASUSTek COMPUTER INC PG34WCDN W4LMAS016832",
    mode     = "3440x1440@360.097",
    position = "0x1440",
    scale    = 1,
    vrr      = 2,
})

hl.monitor({
    output   = "desc:GSV GSV HDMI2.1",
    mode     = "3440x1440@60",
    position = "3640x0",
    scale    = 1,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.workspace_rule({ workspace = "1", monitor = "desc:ASUSTek COMPUTER INC PG34WCDN W4LMAS016832", default = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:LG Electronics LG ULTRAGEAR 103NTBK9D077", default = true })
