{ ... }:

{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font Propo";
        font-weight: bold;
        font-size: 16px;
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

      
      #cpu {
        padding: 0 5px 0 10px;
      }
      #temperature {
        padding: 0 10px 0 10px;
      }
      #clock,
      #memory,
      #network,
      #pulseaudio,
      #bluetooth,
      #tray,
      #mpris,
      #custom-gpu-temp {
        padding: 0 10px;
      }

      #network {
        padding: 0 10px;
        min-width: 160px;
      }

      #custom-power-menu {
        padding: 0 10px;
        color: #f38ba8;
      }

      #custom-power-menu:hover {
        background-color: rgba(243, 139, 168, 0.15);
        border-radius: 8px;
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
          "custom/power-menu"
          # "hyprland/workspaces"
          "niri/workspaces"
          # "hyprland/window"
          "niri/window"
        ];
        modules-center = [  ];
        modules-right = [
          "tray"
          "mpris"
          "pulseaudio"
          "network"
          "custom/gpu-temp"
          "cpu"
          "temperature"
          "memory"
          "clock"
        ];
        # "hyprland/workspaces" = {
        #   format = "{id}";
        #   active-only = false;
        #   persistent-workspaces = {
        #     "*" = [ 1 2 3 4 ];
        #   };
        # };
        # "hyprland/window" = {
        #   max-length = 60;
        # };
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
        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          format = "{temperatureC}°C";
          critical-threshold = 80;
          format-critical = "<span color=\"#f38ba8\">{temperatureC}°C</span>";
          interval = 5;
        };
        "custom/gpu-temp" = {
          exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits";
          format = "<span color=\"#cba6f7\"> </span> {}°C";
          interval = 5;
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
          format-muted = "<span color=\"#6c7086\"></span> 0%";
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        mpris = {
          format = "<span color=\"#a6e3a1\">󰝚</span> {title} - {artist}";
          format-paused = "<span color=\"#6c7086\"></span> {title} - {artist}";
        };
        tray = {
          spacing = 10;
        };
        "custom/power-menu" = {
          format = "";
          tooltip = false;
          on-click = "sh -c 'choice=$(printf \"\\u23fb  Shutdown\\n\\uf021 Reboot\\n\\u23fe Suspend\\n\\u23cd Hibernate\" | rofi -dmenu -p \"Power\" -i) && case $choice in *Shutdown*) systemctl poweroff;; *Reboot*) systemctl reboot;; *Suspend*) systemctl suspend;; *Hibernate*) systemctl hibernate;; esac'";
        };
      }
    ];
  };
}
