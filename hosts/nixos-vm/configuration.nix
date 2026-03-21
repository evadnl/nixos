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

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 5900 ];

  system.stateVersion = "25.11";

}

