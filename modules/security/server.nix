{
  config,
  lib,
  ...
}:

let
  cfg = config.security.hardening.server;
in
{
  options.security.hardening.server = {
    enable = lib.mkEnableOption "server hardening profile";
  };

  config = lib.mkIf cfg.enable {
    # Fail2ban — ban IPs after repeated failed SSH login attempts
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        multipliers = "2 4 8 16 32 64";
        maxtime = "168h"; # cap at 1 week
      };
    };

    # Kernel audit log
    security.auditd.enable = true;

    # Disable suspend and hibernate — servers should not sleep
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    # Blacklist kernel modules not needed on a server
    boot.blacklistedKernelModules = [
      "usb-storage"
      "firewire-core"
      "thunderbolt"
    ];
  };
}
