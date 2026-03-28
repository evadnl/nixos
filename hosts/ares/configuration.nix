{ pkgs, ... }:

{
  os.secureBoot.enable = true;
  drivers.nvidia.enable = true;
  drivers.amdCpu.enable = true;
  network.firewall.enable = true;

  # User
  user = {
    enable = true;
    name = "evad";
    wheel = true;
    extraGroups = [ "networkmanager" ];
    initialPassword = "changeme";
    sshPrivateKey.enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQhHxbdxyugSWR/w0EfjXl7HlCFqE5/WoonT7z8I27R evad@mac-mini"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKD/PwfpR53eyK9lKcatVPEscMEv4nosDF23VeU0vqT evad@macbook-pro"
    ];
  };

  sops.defaultSopsFile = ../../secrets.yaml;

  # Network
  networking.hostName = "ares";
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
