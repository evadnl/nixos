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
      powerManagement.enable = true;
    };
    hardware.graphics.enable = true;
    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
    environment.variables = {
      __GL_THREADED_OPTIMIZATION=1;
      __GL_SHADER_DISK_CACHE=1;
      __GL_SHADER_DISK_CACHE_PATH="/mnt/games1/shader_cache";
    };
  };
}
