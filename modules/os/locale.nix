{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "en_GB.UTF-8";

  # TTY console
  console.keyMap = "us-acentos";

  # X11/Wayland
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };
}