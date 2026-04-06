{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.drivers.nvidia;
in
{
  options.drivers.nvidia = {
    enable = lib.mkEnableOption "NVIDIA graphics driver";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      open = true; # Required for Blackwell (RTX 5080)
    };
    hardware.graphics.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nvtop
  ];
}
