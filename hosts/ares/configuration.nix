{ pkgs, ... }:

{
  # ===========================================================
  # SYSTEM
  # ===========================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Prevent systemd from freezing user session cgroups before sleep —
  # required for NVIDIA open module to properly release GPU resources
  systemd.sleep.settings.Sleep.FreezeUserSessions = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };
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
  hardware.mouse.logitech.enable = true;
  hardware.enableRedistributableFirmware = true;


  # ===========================================================
  # DESKTOP
  # ===========================================================

  desktop.regreet.enable = true;
  # desktop.hyprland.enable = true;
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

fileSystems."/mnt/nas/downloads" = {
  device = "nas01.evad.nl:/volume1/Download";
  fsType = "nfs";
  options = [
    "nfsvers=4"
    "noatime"
    "soft" "timeo=30" "retrans=3"
    "_netdev"
    "noauto" "x-systemd.automount"
    "x-systemd.idle-timeout=300"
    "x-systemd.mount-timeout=10"
  ];
};

fileSystems."/mnt/nas/fotos" = {
  device = "nas01.evad.nl:/volume1/fotos";
  fsType = "nfs";
  options = [
    "nfsvers=4"
    "noatime"
    "soft" "timeo=30" "retrans=3"
    "_netdev"
    "noauto" "x-systemd.automount"
    "x-systemd.idle-timeout=300"
    "x-systemd.mount-timeout=10"
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
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Hide unmanaged partitions from Thunar/udisks2 sidebar
  services.udev.extraRules = ''
    # sda (old Windows drive) — all partitions
    ENV{ID_FS_UUID}=="F604-6C18", ENV{UDISKS_IGNORE}="1"
    ENV{ID_FS_UUID}=="2E2006D62006A4C5", ENV{UDISKS_IGNORE}="1"
    ENV{ID_FS_UUID}=="E4CEDBEACEDBB352", ENV{UDISKS_IGNORE}="1"
    # nvme1n1p1 NTFS "GAMES" partition (not in fstab)
    ENV{ID_FS_UUID}=="B47A52777A5235F8", ENV{UDISKS_IGNORE}="1"
  '';

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  services.tumbler.enable = true;


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
    lm_sensors
    nfs-utils
    sops
    age
    ssh-to-age
  ];
}
