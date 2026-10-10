hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 2,

        col = {
            active_border   = "rgb(89b4fa)",
            inactive_border = "rgb(181825)",
        },

        resize_on_border = true,

        snap = {
            enabled      = true,
            respect_gaps = true,
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 0,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },

    cursor = {
        default_monitor = "desc:ASUSTek COMPUTER INC PG34WCDN W4LMAS016832",
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})
