{ lib, pkgs, config, ... }:

let
  cfg = config.hardware.ddc;
in
{
  options.hardware.ddc = {
    enable = lib.mkEnableOption "DDC/CI monitor control (ddcutil)";
  };

  config = lib.mkIf cfg.enable {
    hardware.i2c.enable = true;

    environment.systemPackages = with pkgs; [
      ddcutil
    ];
  };
}
