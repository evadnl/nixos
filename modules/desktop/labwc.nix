{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.labwc;
in
{
  options.desktop.labwc = {
    enable = lib.mkEnableOption "labwc desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.labwc.enable = true;

    programs.uwsm = {
      enable = true;
      waylandCompositors.labwc = {
        prettyName = "labwc";
        comment = "labwc compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/labwc";
      };
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
