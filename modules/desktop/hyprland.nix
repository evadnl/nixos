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
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --issue --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      kitty
    ];
  };
}
