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
  bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;


  # ===========================================================
  # DESKTOP
  # ===========================================================

  desktop.regreet.enable = true;
  desktop.hyprland.enable = true;
  desktop.niri.enable = true;
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
  # FILESYSTEMS
  # ===========================================================

fileSystems."/mnt/games1" = {
  device = "/dev/disk/by-uuid/4d0035c0-704f-4752-9694-498c956a0c1b";
  fsType = "btrfs";
  options = [ 
    "defaults" 
    "noatime" 
    "compress=zstd" 
    "ssd" 
    "discard=async" 
  ];
};


  # fileSystems."/mnt/games" = {
  #   device = "/dev/disk/by-uuid/B47A52777A5235F8";
  #   fsType = "ntfs3";
  #   options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" "nofail" ];
  # };

  # fileSystems."/mnt/games2" = {
  #   device = "/dev/disk/by-uuid/226C5C266C5BF351";
  #   fsType = "ntfs3";
  #   options = [ "uid=1000" "gid=100" "dmask=022" "fmask=133" "nofail" ];
  # };


  # ===========================================================
  # SERVICES
  # ===========================================================

  services.openssh.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;


  # ===========================================================
  # PACKAGES
  # ===========================================================

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
    fastfetch
    networkmanager
  ];
}
