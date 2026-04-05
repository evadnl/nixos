{ lib, config, ... }:

let
  cfg = config.bluetooth;
in
{
  options.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          ControllerMode = "bredr";
        };
      };
    };

    services.blueman.enable = true;
  };
}
