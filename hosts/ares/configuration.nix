{ pkgs, ... }:

{
  # ===========================================================
  # SYSTEM
  # ===========================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  security.hardening.profile = "workstation";
  system.stateVersion = "26.05";
  programs.nix-ld.enable = true;


  # ===========================================================
  # HARDWARE
  # ===========================================================

  os.secureBoot.enable = true;
  os.wayland.enable = true;
  drivers.nvidia.enable = true;
  drivers.amdCpu.enable = true;


  # ===========================================================
  # DESKTOP
  # ===========================================================

  desktop.hyprland.enable = true;
  gaming.enable = true;


  # ===========================================================
  # USER
  # ===========================================================

  user = {
    enable = true;
    name = "evad";
    wheel = true;
    extraGroups = [ "networkmanager" ];
    initialPassword = "changeme";
    sshPrivateKey.enable = true;
    zsh.enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQhHxbdxyugSWR/w0EfjXl7HlCFqE5/WoonT7z8I27R evad@mac-mini"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKD/PwfpR53eyK9lKcatVPEscMEv4nosDF23VeU0vqT evad@macbook-pro"
    ];
  };

  sops.defaultSopsFile = ../../secrets.yaml;


  # ===========================================================
  # NETWORKING
  # ===========================================================

  networking.hostName = "ares";
  networking.networkmanager.enable = true;
  network.firewall.enable = true;


  # ===========================================================
  # SERVICES
  # ===========================================================

  services.openssh.enable = true;


  # ===========================================================
  # PACKAGES
  # ===========================================================

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
    fastfetch
  ];
}
