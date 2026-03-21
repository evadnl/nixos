{ config, lib, pkgs, ... }:

{
  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    htop
    iotop
    fastfetch
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
   keyMap = "us";
  };

  # Dynamic linker compatibility
  programs.nix-ld.enable = true;
}