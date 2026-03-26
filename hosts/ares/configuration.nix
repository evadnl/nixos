{ config, pkgs, ... }:

{

  os.secureBoot.enable = true;

  # Network
  networking.hostName = "ares";
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # User
  users.users.evad = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialPassword = "changeme";
  };

  # Basic packages for first boot
  environment = {
    systemPackages = with pkgs; [
      vim
      git
      curl
      htop
      fastfetch
      ghostty
      sbctl
    ];
  };

  # Enable SSH so you can work from another machine if needed
  services.openssh.enable = true;

  # Nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # NixOS release
  system.stateVersion = "26.05";
}
