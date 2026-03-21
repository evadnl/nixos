{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
   keyMap = "us";
  };


  users.users.daveops = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQhHxbdxyugSWR/w0EfjXl7HlCFqE5/WoonT7z8I27R"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    htop
  ];

  services.openssh.enable = true;


  system.stateVersion = "25.11";

}

