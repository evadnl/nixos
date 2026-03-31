# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal NixOS flake configuration managing multiple systems. Each host lives under `hosts/<hostname>/` and is wired into `flake.nix`.

## Common Commands

```bash
# Apply config to the current system (run on the NixOS machine)
sudo nixos-rebuild switch --flake .#<hostname>

# Test without making permanent (rolls back on reboot)
sudo nixos-rebuild test --flake .#<hostname>

# Build without applying (useful for checking errors)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Format Nix files
nixfmt **/*.nix
```

## Architecture

```
flake.nix          # Inputs: nixpkgs (unstable), disko, lanzaboote, sops-nix, home-manager
secrets.yaml       # SOPS-encrypted secrets (age)
.sops.yaml         # age key configuration for hosts and users
hosts/
  <hostname>/
    configuration.nix           # Host-specific NixOS config
    hardware-configuration.nix  # Hardware scan output
    home-configuration.nix      # Imports home-manager modules for this host
modules/
  common.nix       # Shared packages applied across all hosts
  desktop/         # Desktop environments (desktop.hyprland.enable)
  drivers/         # Hardware drivers (drivers.amdCpu.enable, drivers.nvidia.enable)
  network/         # Firewall with SSH subnet restrictions (network.firewall.enable)
  os/              # Locale, Lanzaboote secure boot, Wayland (os.secureBoot.enable, os.wayland.enable)
  security/        # System hardening profiles (security.hardening.profile)
  user/            # Primary user configuration (user.enable)
  home/
    base.nix                    # Home-manager base (stateVersion, etc.)
    desktop/                    # fonts, hyprland, waybar
    services/                   # dunst
    apps/
      browsers/firefox.nix
      dev/claude-code.nix
      editors/
        vscode.nix              # programs.vscode.profiles.default.{extensions,userSettings}
        zed.nix                 # programs.zed-editor.{extensions,userSettings}
      social/discord.nix
      terminals/ghostty.nix
```

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/hardware-configuration.nix`
2. Add the host to `flake.nix` under `nixosConfigurations.<hostname>`, importing the relevant modules
3. If the host needs SOPS secrets: get its age public key (`ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`), add it to `.sops.yaml`, then run `sops updatekeys secrets.yaml`
4. Structure `configuration.nix` using the standard section headers (see below)

## Module Conventions

All modules follow the same pattern:
- Expose a NixOS option (e.g. `options.foo.enable`) so features can be toggled per-host
- Wrap all config in `lib.mkIf cfg.enable { ... }`
- Use `let cfg = config.<namespace>; in` at the top

When adding a new module, wire it into the relevant hosts in `flake.nix`.

## Host Configuration Structure

Each `configuration.nix` uses consistent section headers in this order. Omit sections that don't apply to the host (e.g. no DESKTOP on a server).

```nix
# ===========================================================
# SYSTEM
# ===========================================================
# Boot loader, stateVersion, nix settings, security profile

# ===========================================================
# HARDWARE
# ===========================================================
# Host-specific hardware modules: drivers, secure boot

# ===========================================================
# DESKTOP
# ===========================================================
# Display environment — omit on headless/server hosts

# ===========================================================
# USER
# ===========================================================
# Primary user config and SOPS secrets

# ===========================================================
# NETWORKING
# ===========================================================
# Hostname, networkmanager, firewall

# ===========================================================
# SERVICES
# ===========================================================
# System services (openssh, etc.)

# ===========================================================
# PACKAGES
# ===========================================================
# Host-specific system packages
```

## Key Modules

### User (`user.*`)
Declarative primary user. Set `user.sshPrivateKey.enable = true` to deploy the `ssh_private_key` secret from `secrets.yaml` to `/home/<user>/.ssh/id_ed25519` (symlink to `/run/secrets/ssh_private_key`). Authorized keys go in `user.authorizedKeys` — NixOS places them at `/etc/ssh/authorized_keys.d/<user>`, not `~/.ssh/authorized_keys`.

### Hyprland (`desktop.hyprland.enable`)
Wayland compositor with Pipewire audio (PulseAudio + ALSA compat), rtkit for realtime scheduling, and greetd/tuigreet login manager. The greeter pre-fills the username from `config.user.name`. Enable alongside `os.wayland.enable` on any desktop host.

### Wayland (`os.wayland.enable`)
Sets NVIDIA-specific Wayland environment variables (`GBM_BACKEND`, `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME`, `NVD_BACKEND`, `NIXOS_OZONE_WL`). Enable on any host running a Wayland compositor with an NVIDIA GPU.

### Security hardening (`security.hardening.profile`)
Set to `"workstation"` or `"server"`. Both profiles apply base hardening (SSH, kernel sysctl, protectKernelImage, sudo.execWheelOnly). The workstation profile adds AppArmor; the server profile adds fail2ban, auditd, disabled sleep targets, and blacklisted USB/Firewire/Thunderbolt kernel modules.

### Secure Boot (`os.secureBoot.enable`)
Wraps lanzaboote. Initial enrollment on a new machine:
```bash
sudo sbctl create-keys
sudo sbctl enroll-keys
```

### SOPS secrets
Secrets are encrypted with age keys. Each host decrypts using its SSH host key (`/etc/ssh/ssh_host_ed25519_key`). The user's personal age key is also a recipient so secrets can be edited from a dev machine. Edit secrets with `sops secrets.yaml`.

## Unfree Packages

Set `nixpkgs.config.allowUnfree = true` on any host that requires proprietary software (e.g. NVIDIA driver).

## Home Manager

Wired into hosts via `modules/home/default.nix`, which injects the host's `home-configuration.nix` as `hostHomeModule`. Each host's `home-configuration.nix` imports the relevant `modules/home/**` files.

**Important:** new files added to `modules/home/` must be `git add`-ed before Nix can resolve them — the flake copies only git-tracked files into the store.
