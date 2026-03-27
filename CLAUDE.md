# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal NixOS flake configuration managing two systems:
- **ares**: Main workstation (AMD Ryzen 7 9800X3D + RTX 5080, Secure Boot via Lanzaboote)
- **nixos-vm**: QEMU virtual machine for testing

## Common Commands

```bash
# Apply config to the current system (run on the NixOS machine)
sudo nixos-rebuild switch --flake .#ares
sudo nixos-rebuild switch --flake .#nixos-vm

# Test without making permanent (rolls back on reboot)
sudo nixos-rebuild test --flake .#ares

# Build without applying (useful for checking errors)
nix build .#nixosConfigurations.ares.config.system.build.toplevel

# Format Nix files
nixfmt **/*.nix
```

## Architecture

```
flake.nix          # Inputs: nixpkgs (unstable), disko, lanzaboote, home-manager (unused)
hosts/
  ares/            # Hardware config + host-specific packages/users
  nixos-vm/        # Simpler VM config with wayvnc for headless access
modules/
  common.nix       # Shared packages applied across hosts
  hyprland.nix     # Wayland compositor, Pipewire audio, greetd login
  drivers/         # Hardware drivers (AMD CPU microcode, NVIDIA closed-source)
  os/              # OS-level: locale (Europe/Amsterdam, en_US), lanzaboote secure boot
  services/        # (empty, reserved for future services)
  user/            # (empty, reserved for future user configs)
```

### How Modules Are Wired

Each host's `configuration.nix` imports modules from `../../modules/`. Modules use NixOS option patterns (e.g., `options.os.secureBoot.enable`) so features can be toggled per-host. The `ares` host uses disko for declarative disk partitioning — disk is identified by ID, not device name (see [hosts/ares/disk.nix](hosts/ares/disk.nix)).

### Secure Boot (Lanzaboote)

The `modules/os/lanzaboote.nix` module wraps the upstream lanzaboote module with a local `os.secureBoot.enable` option. Initial enrollment requires:
```bash
sudo sbctl create-keys
sudo sbctl enroll-keys
```

### Unfree Packages

`nixpkgs.config.allowUnfree = true` is set globally; this is required for the NVIDIA driver.

### Home Manager

Listed as a flake input but currently commented out — not yet wired into any host configuration.
