{
  config,
  lib,
  ...
}:

let
  cfg = config.security.hardening;
in
{
  options.security.hardening = {
    profile = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "workstation" "server" ]);
      default = null;
      description = "Hardening profile to apply. Enables base hardening and the appropriate profile.";
    };
  };

  config = lib.mkIf (cfg.profile != null) {
    # Enable the appropriate sub-profile
    security.hardening.workstation.enable = lib.mkIf (cfg.profile == "workstation") true;
    security.hardening.server.enable = lib.mkIf (cfg.profile == "server") true;

    # Clean /tmp on every boot to prevent leftover sensitive data
    boot.tmp.cleanOnBoot = true;

    # Prevent writing to kernel image (/dev/mem, /dev/kmem)
    security.protectKernelImage = true;

    # Only allow sudo for binaries in the secure PATH, not arbitrary scripts
    security.sudo.execWheelOnly = true;

    # SSH hardening
    services.openssh = lib.mkIf config.services.openssh.enable {
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        LoginGraceTime = 30;
        MaxAuthTries = 3;
      };
      extraConfig = ''
        AllowAgentForwarding no
        AllowTcpForwarding no
      '';
    };

    # Kernel hardening via sysctl
    boot.kernel.sysctl = {
      # Hide kernel pointers from unprivileged users
      "kernel.kptr_restrict" = 2;

      # Restrict dmesg to privileged users
      "kernel.dmesg_restrict" = 1;

      # Restrict ptrace to parent processes only
      "kernel.yama.ptrace_scope" = 1;

      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;

      # Disable ICMP redirect acceptance
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;

      # Disable sending ICMP redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;

      # Reverse path filtering — drop packets with spoofed source addresses
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
    };
  };
}
