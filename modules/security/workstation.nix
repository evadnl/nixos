{
  config,
  lib,
  ...
}:

let
  cfg = config.security.hardening.workstation;
in
{
  options.security.hardening.workstation = {
    enable = lib.mkEnableOption "workstation hardening profile";
  };

  config = lib.mkIf cfg.enable {
    # AppArmor — mandatory access control, confines programs to defined profiles
    security.apparmor.enable = true;
  };
}
