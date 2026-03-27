# NixOS Configuration

Personal NixOS flake configuration managing two systems.

## Systems

| Host | Description |
|------|-------------|
| **ares** | Main workstation — AMD Ryzen 7 9800X3D + RTX 5080, Secure Boot via Lanzaboote |
| **nixos-vm** | QEMU virtual machine for testing, headless access via wayvnc |

## Usage

```bash
# Apply config to the current system
sudo nixos-rebuild switch --flake .#ares
sudo nixos-rebuild switch --flake .#nixos-vm

# Test without making permanent (rolls back on reboot)
sudo nixos-rebuild test --flake .#ares

# Build without applying (useful for checking errors)
nix build .#nixosConfigurations.ares.config.system.build.toplevel

# Format Nix files
nixfmt **/*.nix
```

## Structure

```
flake.nix          # Inputs: nixpkgs (unstable), disko, lanzaboote
hosts/
  ares/            # Hardware config, disk layout (disko/btrfs), host packages
  nixos-vm/        # Simpler VM config with wayvnc
modules/
  common.nix       # Shared packages across hosts
  hyprland.nix     # Wayland compositor, Pipewire audio, greetd login
  drivers/
    amd-cpu.nix    # AMD microcode updates
    nvidia.nix     # NVIDIA closed-source driver (open kernel module for Blackwell)
  networking/
    firewall.nix   # nftables firewall, SSH restricted to trusted subnets
  os/
    locale.nix     # Timezone (Europe/Amsterdam), keyboard (us-intl)
    lanzaboote.nix # Secure Boot module wrapping upstream lanzaboote
```

## Secure Boot (ares only)

Lanzaboote is used for Secure Boot. Initial key enrollment:

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys
```

## MCP Server

This repo includes an `.mcp.json` that configures the [mcp-nixos](https://github.com/utensils/mcp-nixos) server for use with Claude Code. It allows querying NixOS options, packages, and documentation directly from the editor.

> **Prerequisite:** The [Nix package manager](https://nixos.org/download/) must be installed on your machine, as the MCP server is run via `nix run`.
