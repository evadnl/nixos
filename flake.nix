{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, disko, ...}: {
    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos-vm/configuration.nix
        ./modules/hyprland.nix
        ./modules/common.nix
      ];
    };

    nixosConfigurations.ares = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./hosts/ares/disk.nix
        ./hosts/ares/configuration.nix
        ./hosts/ares/hardware-configuration.nix
        ./modules/amd-cpu.nix
        ./modules/nvidia.nix
        ./modules/locale.nix
      ];
    };
  };
}
