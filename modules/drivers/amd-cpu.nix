{
  config,
  lib,
  ...
}:

let
  cfg = config.drivers.amdCpu;
in
{
  options.drivers.amdCpu = {
    enable = lib.mkEnableOption "AMD CPU microcode updates";
  };

  config = lib.mkIf cfg.enable {
    hardware.cpu.amd.updateMicrocode = true;
  };
}
