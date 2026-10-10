{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.apps.sunshine;
  asusMode =
    mode:
    pkgs.writeShellScript "sunshine-asus-${mode}" ''
      exec ${lib.getExe' pkgs.niri "niri"} msg output "ASUSTek COMPUTER INC PG34WCDN W4LMAS016832" mode ${mode}
    '';
  tcpPorts = [
    47984
    47989
    48010
  ];
  udpPorts = [
    47998
    47999
    48000
  ];
  rule =
    proto: port: subnet:
    "iptables -A nixos-fw -s ${subnet} -p ${proto} --dport ${toString port} -j nixos-fw-accept";
  rules = lib.concatLists (
    map (
      subnet: map (port: rule "tcp" port subnet) tcpPorts ++ map (port: rule "udp" port subnet) udpPorts
    ) (config.network.firewall.trustedSubnets ++ cfg.extraSubnets)
  );
in
{
  options.apps.sunshine = {
    enable = lib.mkEnableOption "Sunshine game-stream host, reachable from trusted LAN subnets only";

    extraSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional subnets allowed to reach Sunshine's streaming ports only, e.g. an IoT VLAN with Moonlight clients.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      package = pkgs.sunshine.override { cudaSupport = true; };
      autoStart = true;
      capSysAdmin = true;
      openFirewall = false;
      settings.global_prep_cmd = builtins.toJSON [
        {
          do = "${asusMode "1920x1080@119.879"}";
          undo = "${asusMode "3440x1440@360.097"}";
        }
      ];
    };

    networking.firewall.extraCommands = lib.concatStringsSep "\n" rules;
  };
}
