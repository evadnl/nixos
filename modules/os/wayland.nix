{
  config,
  lib,
  ...
}:

let
  cfg = config.os.wayland;
in
{
  options.os.wayland = {
    enable = lib.mkEnableOption "Wayland display protocol support";
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };
}
