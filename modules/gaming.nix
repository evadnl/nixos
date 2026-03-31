{ lib, config, pkgs, ... }:

let
  cfg = config.gaming;
in
{
  options.gaming.enable = lib.mkEnableOption "gaming profile";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };

    hardware.steam-hardware.enable = true;
  };
}
