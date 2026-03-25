{ config, pkgs, ... }:

{
  # Hostname
  networking.hostName = "ares";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Timezone & Locale
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

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
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
    fastfetch
  ];

  # Enable SSH so you can work from another machine if needed
  services.openssh.enable = true;

  # Nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # NixOS release
  system.stateVersion = "25.11";
}
