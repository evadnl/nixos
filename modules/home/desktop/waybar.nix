{ ... }:

{
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "bluetooth"
          "tray"
          "clock"
        ];
        "hyprland/workspaces" = {
          format = "{id}";
          active-only = false;
        };
        "hyprland/window" = {
          max-length = 60;
        };
        clock = {
          format = "{:%a %b %e %H:%M}";
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
        bluetooth = {
          format = "BT";
          format-connected = "BT {device_alias}";
          format-disabled = "";
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
        };
        tray = {
          spacing = 10;
        };
      }
    ];
  };
}
