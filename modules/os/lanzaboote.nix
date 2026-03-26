{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.os.secureBoot;
in
{
  options.os.secureBoot = {
    enable = lib.mkEnableOption "Lanzaboote secure boot";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    })

    {
      environment.systemPackages = [ pkgs.sbctl ];
    }
  ];
}
