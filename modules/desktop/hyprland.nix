{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.hyprland;
in
{
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    environment.etc."issue".text = ''
      ███▄▄▄▄    ▄█  ▀████     ████▀  ▄██████▄     ▄████████
      ███▀▀▀██▄ ███    ███    ████▀  ███    ███   ███    ███
      ███   ███ ███     ███   ███    ███    ███   ███    █▀
      ███   ███ ███     ▀███▄███▀    ███    ███   ███
      ███   ███ ███     ████▀██▄     ███    ███ ▀███████████
      ███   ███ ███     ███  ▀███    ███    ███          ███
      ███   ███ ███   ▄███     ███▄  ███    ███    ▄█    ███
       ▀█   █▀  █▀   ████       ███▄  ▀██████▀   ▄████████▀

                      Follow the white rabbit.
    '';

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --issue --greet-align left --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    environment.etc."xdg/waybar/config.jsonc".text = builtins.toJSON {
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
    };

    environment.systemPackages = with pkgs; [
      kitty
      waybar
      hyprlauncher
      adwaita-icon-theme
    ];
  };
}
