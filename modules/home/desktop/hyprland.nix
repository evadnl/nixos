{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # package = null tells home-manager not to install Hyprland itself,
    # since the NixOS module (programs.hyprland.enable) already does it.
    package = null;
    portalPackage = null;
    # Export all env vars to systemd/dbus so services see the same environment
    # as the terminal (e.g. PATH, WAYLAND_DISPLAY, etc.)
    systemd.variables = [ "--all" ];
  };

  # Pass home-manager session variables into the UWSM session so they are
  # available from startup (required when programs.hyprland.withUWSM = true).
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland.extraConfig = ''
    source = ~/.config/hypr/config/monitors.conf
    source = ~/.config/hypr/config/programs.conf
    source = ~/.config/hypr/config/autostart.conf
    source = ~/.config/hypr/config/environment-variables.conf
    source = ~/.config/hypr/config/permissions.conf
    source = ~/.config/hypr/config/theming.conf
    source = ~/.config/hypr/config/keybinds.conf
    source = ~/.config/hypr/config/input.conf
    source = ~/.config/hypr/config/rules.conf
  '';

  xdg.configFile."hypr/config/monitors.conf".text = ''
    monitor=,3440x1440@144,auto,auto,vrr,1
  '';

  xdg.configFile."hypr/config/programs.conf".text = ''
    $terminal = ghostty
    $fileManager = nautilus
    $menu = fuzzel
  '';

  xdg.configFile."hypr/config/autostart.conf".text = ''
    exec-once = eval $(gnome-keyring-daemon --start --components=secrets,pkcs11)
    exec-once = waybar
    exec-once = blueman-applet
    exec-once = swww-daemon
    exec-once = discord
    exec-once = 1password --silent
    exec-once = ${pkgs.writeShellScript "wallpaper-rotate" ''
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"
      TRANSITIONS=(left right top bottom wipe grow outer)
      while true; do
        wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | shuf -n 1)
        transition=''${TRANSITIONS[$RANDOM % ''${#TRANSITIONS[@]}]}
        swww img "$wallpaper" --transition-type "$transition"
        sleep 900
      done
    ''}
  '';

  xdg.configFile."hypr/config/environment-variables.conf".text = ''
    env = XCURSOR_SIZE,24
    env = HYPRCURSOR_SIZE,24
    env = XKB_DEFAULT_LAYOUT,us
    env = XKB_DEFAULT_VARIANT,intl
    env = GTK_IM_MODULE,simple
    env = QT_IM_MODULE,simple
  '';

  xdg.configFile."hypr/config/permissions.conf".text = ''
    # See https://wiki.hypr.land/Configuring/Permissions/
    # Please note permission changes here require a Hyprland restart and are not applied on-the-fly
    # for security reasons

    # ecosystem {
    #   enforce_permissions = 1
    # }

    # permission = /usr/(bin|local/bin)/grim, screencopy, allow
    # permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow
    # permission = /usr/(bin|local/bin)/hyprpm, plugin, allow
  '';

  xdg.configFile."hypr/config/theming.conf".text = ''
    # Refer to https://wiki.hypr.land/Configuring/Variables/

    # https://wiki.hypr.land/Configuring/Variables/#general
    general {
        gaps_in = 5
        gaps_out = 20

        border_size = 2

        # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false

        # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
        allow_tearing = false

        layout = dwindle
    }

    # https://wiki.hypr.land/Configuring/Variables/#decoration
    decoration {
        rounding = 10
        rounding_power = 2

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0
        inactive_opacity = 1.0

        shadow {
            enabled = true
            range = 4
            render_power = 3
            color = rgba(1a1a1aee)
        }

        # https://wiki.hypr.land/Configuring/Variables/#blur
        blur {
            enabled = true
            size = 3
            passes = 1

            vibrancy = 0.1696
        }
    }

    # https://wiki.hypr.land/Configuring/Variables/#animations
    animations {
        enabled = yes, please :)

        # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
        #        NAME,           X0,   Y0,   X1,   Y1
        bezier = easeOutQuint,   0.23, 1,    0.32, 1
        bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
        bezier = linear,         0,    0,    1,    1
        bezier = almostLinear,   0.5,  0.5,  0.75, 1
        bezier = quick,          0.15, 0,    0.1,  1

        # Default animations, see https://wiki.hypr.land/Configuring/Animations/
        #           NAME,          ONOFF, SPEED, CURVE,        [STYLE]
        animation = global,        1,     10,    default
        animation = border,        1,     5.39,  easeOutQuint
        animation = windows,       1,     4.79,  easeOutQuint
        animation = windowsIn,     1,     4.1,   easeOutQuint, popin 87%
        animation = windowsOut,    1,     1.49,  linear,       popin 87%
        animation = fadeIn,        1,     1.73,  almostLinear
        animation = fadeOut,       1,     1.46,  almostLinear
        animation = fade,          1,     3.03,  quick
        animation = layers,        1,     3.81,  easeOutQuint
        animation = layersIn,      1,     4,     easeOutQuint, fade
        animation = layersOut,     1,     1.5,   linear,       fade
        animation = fadeLayersIn,  1,     1.79,  almostLinear
        animation = fadeLayersOut, 1,     1.39,  almostLinear
        animation = workspaces,    1,     1.94,  almostLinear, fade
        animation = workspacesIn,  1,     1.21,  almostLinear, fade
        animation = workspacesOut, 1,     1.94,  almostLinear, fade
        animation = zoomFactor,    1,     7,     quick
    }

    # See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
    dwindle {
        pseudotile = true
        preserve_split = true
    }

    # See https://wiki.hypr.land/Configuring/Master-Layout/ for more
    master {
        new_status = master
        mfact = 0.5
        orientation = center
        slave_count_for_center_master = 0
    }

    # https://wiki.hypr.land/Configuring/Variables/#misc
    misc {
        force_default_wallpaper = -1
        disable_hyprland_logo = false
    }
  '';

  xdg.configFile."hypr/config/keybinds.conf".text = ''
    # See https://wiki.hypr.land/Configuring/Keywords/
    $mainMod = SUPER

    bind = $mainMod, return, exec, $terminal
    bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
    bind = $mainMod, W, killactive,
    bind = $mainMod ALT, W, exec, swww img $(find ~/Pictures/wallpapers -type f | shuf -n 1) --transition-type random
    bind = $mainMod, L, exec, loginctl lock-session
    bind = $mainMod, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
    bind = $mainMod, E, exec, $fileManager
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, space, exec, $menu
    bind = $mainMod, P, pseudo, # dwindle
    bind = $mainMod, J, layoutmsg, togglesplit # dwindle

    # Window management
    bind = $mainMod, F, fullscreen, 0
    bind = ALT, Tab, cyclenext,

    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Move windows with mainMod + SHIFT + arrow keys
    bind = $mainMod SHIFT, left, movewindow, l
    bind = $mainMod SHIFT, right, movewindow, r
    bind = $mainMod SHIFT, up, movewindow, u
    bind = $mainMod SHIFT, down, movewindow, d

    # Resize active window with mainMod + ALT + arrow keys
    binde = $mainMod ALT, right, resizeactive, 30 0
    binde = $mainMod ALT, left, resizeactive, -30 0
    binde = $mainMod ALT, up, resizeactive, 0 -30
    binde = $mainMod ALT, down, resizeactive, 0 30

    # Switch workspaces with mainMod + [0-9]
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Special workspace (scratchpad)
    bind = $mainMod, S, togglespecialworkspace, magic
    bind = $mainMod SHIFT, S, movetoworkspace, special:magic

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    # Multimedia keys
    bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
    bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
    bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

    # Requires playerctl
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPause, exec, playerctl play-pause
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioPrev, exec, playerctl previous
  '';

  xdg.configFile."hypr/config/input.conf".text = ''
    # https://wiki.hypr.land/Configuring/Variables/#input
    input {
        kb_layout = us
        kb_variant = intl
        kb_model =
        kb_options = altwin:swap_lalt_lwin
        kb_rules =

        follow_mouse = 1

        sensitivity = -0.5 # -1.0 - 1.0, 0 means no modification.

        touchpad {
            natural_scroll = false
        }
    }

    # See https://wiki.hypr.land/Configuring/Gestures
    gesture = 3, horizontal, workspace

    device {
        name = epic-mouse-v1
        sensitivity = -0.5
    }
  '';

  xdg.configFile."hypr/config/rules.conf".text = ''
    # See https://wiki.hypr.land/Configuring/Window-Rules/ for more
    # See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

    windowrule {
        # Ignore maximize requests from all apps.
        name = suppress-maximize-events
        match:class = .*

        suppress_event = maximize
    }

    windowrule {
        # Fix some dragging issues with XWayland
        name = fix-xwayland-drags
        match:class = ^$
        match:title = ^$
        match:xwayland = true
        match:float = true
        match:fullscreen = false
        match:pin = false

        no_focus = true
    }

    windowrule {
        name = move-hyprland-run
        match:class = hyprland-run

        move = 20 monitor_h-120
        float = yes
    }

    windowrule {
        name = discord-workspace
        match:class = ^discord$

        workspace = 3
    }

    windowrule {
        name = 1password-dialogs
        match:class = ^1Password$
        match:float = true

        center = true
        rounding = 0
    }
  '';

  home.pointerCursor = {
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    hyprshutdown
    pavucontrol
    playerctl
    swww
    grim
    slurp
    wl-clipboard
  ];
}
