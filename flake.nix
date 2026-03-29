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

    sops-nix = {
      url = "github:Mic92/sops-nix";
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
      sops-nix,
      ...
    }:
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/nixos-vm/configuration.nix
          ./modules/desktop/hyprland.nix
          ./modules/common.nix
          ./modules/user/default.nix
        ];
      };

      nixosConfigurations.ares = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          sops-nix.nixosModules.sops
          ./hosts/ares/disk.nix
          ./hosts/ares/configuration.nix
          ./hosts/ares/hardware-configuration.nix
          ./modules/desktop/hyprland.nix
          ./modules/drivers/amd-cpu.nix
          ./modules/drivers/nvidia.nix
          ./modules/os/locale.nix
          ./modules/os/lanzaboote.nix
          ./modules/os/wayland.nix
          ./modules/network/firewall.nix
          ./modules/user/default.nix
          ./modules/security/default.nix
          ./modules/security/server.nix
          ./modules/security/workstation.nix
        ];
      };
    };
}
