{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    htop
    iotop
    fastfetch
    just
    dnsutils
  ];
}