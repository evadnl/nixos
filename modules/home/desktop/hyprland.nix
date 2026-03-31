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
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  programs.kitty.enable = true; # required for the default Hyprland config

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "tray"
        ];
        "hyprland/workspaces" = { };
        "hyprland/window" = {
          max-length = 60;
        };
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "CPU {usage}%";
          interval = 5;
        };
        memory = {
          format = "MEM {}%";
          interval = 10;
        };
        network = {
          format-wifi = "WiFi {signalStrength}%";
          format-ethernet = "ETH";
          format-disconnected = "Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "VOL {volume}%";
          format-muted = "MUTED";
          on-click = "pavucontrol";
        };
        tray = {
          spacing = 10;
        };
      }
    ];
  };

  home.packages = with pkgs; [
    hyprlauncher
    adwaita-icon-theme
  ];
}
