{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ===========================================================
  # SYSTEM
  # ===========================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";


  # ===========================================================
  # DESKTOP
  # ===========================================================

  desktop.sddm.enable = true;
  desktop.hyprland.enable = true;


  # ===========================================================
  # USER
  # ===========================================================

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


  # ===========================================================
  # NETWORKING
  # ===========================================================

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 5900 ]; # wayvnc


  # ===========================================================
  # SERVICES
  # ===========================================================

  services.openssh.enable = true;


  # ===========================================================
  # PACKAGES
  # ===========================================================

  environment.systemPackages = with pkgs; [
    wayvnc
  ];
}
