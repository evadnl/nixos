{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      nixpkgs,
      disko,
      lanzaboote,
      ...
    }:
    {
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
          lanzaboote.nixosModules.lanzaboote
          ./hosts/ares/disk.nix
          ./hosts/ares/configuration.nix
          ./hosts/ares/hardware-configuration.nix
          ./modules/drivers/amd-cpu.nix
          ./modules/drivers/nvidia.nix
          ./modules/os/locale.nix
          ./modules/os/lanzaboote.nix
          ./modules/networking/firewall.nix
        ];
      };
    };
}
