{ ... }:

{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font Propo";
        font-weight: bold;
        font-size: 12px;
        color: #cdd6f4;
      }

      window#waybar {
        background-color: transparent;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background-color: rgba(24, 24, 37, 0.8);
        border-radius: 12px;
        padding: 0 10px;
      }

      #workspaces button {
        border-bottom: 2px solid transparent;
      }

      #workspaces button.active,
      #workspaces button.focused {
        border-bottom: 2px solid #b4befe;
        background-color: rgba(49, 50, 68, 0.8);
      }

      .modules-center {
        padding: 0 14px;
      }

      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #bluetooth,
      #tray,
      #mpris {
        padding: 0 10px;
      }

      #network {
        padding: 0 10px;
        min-width: 160px;
      }
    '';
    settings = [
      {
        layer = "top";
        position = "top";
        height = 35;
        margin-top = 2;
        margin-left = 4;
        margin-right = 4;
        modules-left = [
          "hyprland/workspaces"
          "niri/workspaces"
          "hyprland/window"
          "niri/window"
        ];
        modules-center = [  ];
        modules-right = [
          "tray"
          "mpris"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "clock"
        ];
        "hyprland/workspaces" = {
          format = "{id}";
          active-only = false;
          persistent-workspaces = {
            "*" = [ 1 2 3 4 ];
          };
        };
        "hyprland/window" = {
          max-length = 60;
        };
        "niri/workspaces" = {
          format = "{index}";
        };
        "niri/window" = {
          max-length = 60;
        };
        clock = {
          format = "<span color=\"#b4befe\">{0:%a %b %e}</span> {0:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "<span color=\"#f38ba8\"></span> {usage}%";
          interval = 5;
        };
        memory = {
          format = "<span color=\"#a6e3a1\"></span> {}%";
          interval = 10;
        };
        network = {
          format-wifi = "<span color=\"#89b4fa\"></span> {essid} {signalStrength}% ↑{bandwidthUpBits} ↓{bandwidthDownBits}";
          format-ethernet = "<span color=\"#89b4fa\"></span> ↑{bandwidthUpBits} ↓{bandwidthDownBits}";
          format-disconnected = "<span color=\"#6c7086\">Disconnected</span>";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{ifname}: {ipaddr}/{cidr}\nESSID: {essid}\nSignal: {signalStrength}%\nFrequency: {frequency}GHz";
          interval = 2;
        };
        pulseaudio = {
          format = "<span color=\"#f9e2af\"></span> {volume}%";
          format-muted = "<span color=\"#6c7086\"></span>";
          on-click = "pavucontrol";
        };
        mpris = {
          format = "<span color=\"#a6e3a1\">󰝚</span> {title} - {artist}";
          format-paused = "<span color=\"#6c7086\"></span> {title} - {artist}";
        };
        tray = {
          spacing = 10;
        };
      }
    ];
  };
}
