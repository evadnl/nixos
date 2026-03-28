{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  desktop.hyprland.enable = true;

  # User
  user = {
    enable = true;
    name = "daveops";
    wheel = true;
    extraGroups = [
      "video"
      "audio"
      "input"
      "render"
      "networkmanager"
    ];
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQhHxbdxyugSWR/w0EfjXl7HlCFqE5/WoonT7z8I27R"
    ];
    packages = with pkgs; [ tree ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    wayvnc
  ];

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 5900 ]; # wayvnc

  system.stateVersion = "25.11";
}
