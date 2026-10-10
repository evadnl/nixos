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
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;
    };

    services.libinput.enable = true;

    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common."org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };

    environment.systemPackages = [ pkgs.pulseaudio ];

  };
}
