{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.niri;
in
{
  options.desktop.niri = {
    enable = lib.mkEnableOption "Niri desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.xwayland.enable = true;

    environment.systemPackages = [ pkgs.xwayland-satellite ];

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;
    };

    services.libinput.enable = true;

    security.pam.services.swaylock = { };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common."org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };

  };
}
