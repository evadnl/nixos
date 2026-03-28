{
  config,
  lib,
  ...
}:

let
  cfg = config.network.firewall;
  allowedSSHSubnets = [
    "192.168.1.0/24"
    "10.30.0.0/24"
    "10.40.0.0/24"
    "10.50.0.0/24"
  ];
  subnetList = lib.concatStringsSep ", " allowedSSHSubnets;
in
{
  options.network.firewall = {
    enable = lib.mkEnableOption "custom firewall rules";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = true;
    networking.firewall.allowPing = false;

    # Auto-open SSH only from trusted subnets when openssh is enabled
    networking.firewall.extraInputRules = lib.mkIf config.services.openssh.enable ''
      ip saddr { ${subnetList} } tcp dport 22 accept
    '';
  };
}
