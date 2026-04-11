{ lib, pkgs, config, ... }:

let
  cfg = config.hardware.mouse;
in
{
  options.hardware.mouse = {
    logitech.enable = lib.mkEnableOption "Logitech mouse support (Solaar + Piper/libratbag)";
  };

  config = lib.mkIf cfg.logitech.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    services.ratbagd.enable = true;

    environment.systemPackages = with pkgs; [
      solaar
      piper
      libratbag
    ];
  };
}
