{ lib, pkgs, config, ... }:

let
  cfg = config.hardware.mouse;
in
{
  options.hardware.mouse = {
    logitech.enable = lib.mkEnableOption "Logitech mouse support (Solaar)";
  };

  config = lib.mkIf cfg.logitech.enable {
    hardware.logitech.wireless.enable = true;

    programs.solaar.enable = true;
  };
}
