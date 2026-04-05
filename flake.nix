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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      nixpkgs,
      disko,
      lanzaboote,
      sops-nix,
      home-manager,
      catppuccin,
      ...
    }:
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostHomeModule = ./hosts/nixos-vm/home-configuration.nix;
          catppuccinHomeModule = catppuccin.homeModules.catppuccin;
        };
        modules = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/nixos-vm/configuration.nix
          ./modules/desktop/regreet.nix
          ./modules/desktop/hyprland.nix
          ./modules/common.nix
          ./modules/user/default.nix
          ./modules/home/default.nix
        ];
      };

      nixosConfigurations.ares = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostHomeModule = ./hosts/ares/home-configuration.nix;
          catppuccinHomeModule = catppuccin.homeModules.catppuccin;
        };
        modules = [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          sops-nix.nixosModules.sops
          ./hosts/ares/disk.nix
          ./hosts/ares/configuration.nix
          ./hosts/ares/hardware-configuration.nix
          ./modules/common.nix
          ./modules/apps/1password.nix
          ./modules/gaming.nix
          ./modules/hardware/bluetooth.nix
          ./modules/desktop/regreet.nix
          ./modules/desktop/hyprland.nix
          ./modules/desktop/niri.nix
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
          ./modules/home/default.nix
        ];
      };

      homeConfigurations."evad@nixos-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        modules = [
          catppuccin.homeModules.catppuccin
          ./hosts/nixos-vm/home-configuration.nix
          {
            home.username = "evad";
            home.homeDirectory = "/home/evad";
          }
        ];
      };

      homeConfigurations."evad@ares" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        modules = [
          catppuccin.homeModules.catppuccin
          ./hosts/ares/home-configuration.nix
          {
            home.username = "evad";
            home.homeDirectory = "/home/evad";
          }
        ];
      };
    };
}
