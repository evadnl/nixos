{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.plasma;
in
{
  options.desktop.plasma = {
    enable = lib.mkEnableOption "KDE Plasma desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager.enable = true;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;
    };

    services.blueman.enable = false;
    services.gnome.gnome-keyring.enable = false;

    environment.systemPackages = [ pkgs.kdePackages.libkscreen ];
  };
}
