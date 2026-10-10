# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal NixOS flake configuration. There is currently one host: `ares`, the main workstation. Each host lives under `hosts/<hostname>/` and is wired into `flake.nix`.

## Common Commands

Recipes live in the `justfile` and are the preferred entry point:

```bash
just switch <host>          # Apply configuration
just test <host>            # Test without making permanent (rolls back on reboot)
just build <host>           # Build without applying (useful for checking errors)
just update <host>          # Update flake inputs and switch
just home <user> <host>     # Apply home-manager config only (faster, no sudo)
just clean [days]           # Remove generations older than N days (default 7) and GC
just fmt                    # Format all Nix files
just secrets                # Edit SOPS secrets
just update-keys            # Re-encrypt secrets after adding a host to .sops.yaml
just host-key               # Print this machine's age public key (run on the new host)
```

The underlying commands, when `just` is not available:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
sudo nixos-rebuild test --flake .#<hostname>
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
nixfmt **/*.nix
```

To check a change evaluates without building it:

```bash
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath
```

## Architecture

```
flake.nix          # Inputs: nixpkgs (unstable), disko, lanzaboote, sops-nix,
                   # home-manager, catppuccin, noctalia, zen-browser, nur
justfile           # Task recipes (see Common Commands)
secrets.yaml       # SOPS-encrypted secrets (age)
.sops.yaml         # age key configuration for hosts and users
hosts/
  ares/
    configuration.nix           # Host-specific NixOS config
    hardware-configuration.nix  # Hardware scan output
    disk.nix                    # disko declarative partitioning
    home-configuration.nix      # Imports home-manager modules for this host
modules/
  common.nix       # Shared packages applied across all hosts
  gaming.nix       # Steam/gamemode profile (gaming.enable)
  apps/            # System-level apps (1password)
  desktop/         # Compositors and greeters (desktop.niri, desktop.hyprland,
                   # desktop.regreet, desktop.sddm)
  drivers/         # Hardware drivers (drivers.amdCpu.enable, drivers.nvidia.enable)
  hardware/        # bluetooth.enable, hardware.mouse.logitech.enable, hardware.ddc.enable
  network/         # Firewall with SSH subnet restrictions (network.firewall.enable)
  os/              # Locale, Lanzaboote secure boot, Wayland (os.secureBoot.enable, os.wayland.enable)
  security/        # System hardening profiles (security.hardening.profile)
  user/            # Primary user configuration (user.enable)
  home/
    base.nix                    # Home-manager base (stateVersion, etc.)
    default.nix                 # Wires home-manager into the system
    desktop/
      niri.nix                  # Niri config; assembles the KDL fragments in niri/
      niri/                     # outputs, inputs, layout, keybinds, rules, autostart
      ...                       # cursor, fonts, gtk, noctalia, waybar, fuzzel, rofi,
                                # hyprland/hyprlock/hypridle
    shell/                      # zsh, starship, ssh
    services/                   # dunst
    apps/
      browsers/                 # firefox.nix, zen.nix
      dev/                      # claude-code.nix, nodejs.nix
      editors/
        vscode.nix              # programs.vscode.profiles.default.{extensions,userSettings}
        zed.nix                 # programs.zed-editor.{extensions,userSettings}
      files/                    # thunar.nix, nautilus.nix
      gaming/default.nix
      hardware/streamdeck.nix
      media/                    # spotify.nix, vlc.nix
      social/                   # discord.nix, whatsapp.nix
      terminals/ghostty.nix
```

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/hardware-configuration.nix`
2. Add the host to `flake.nix` under `nixosConfigurations.<hostname>`, importing the relevant modules. Pass `hostHomeModule` (plus the `catppuccin`/`noctalia`/`zen-browser` home modules) in `specialArgs`, and add a matching `homeConfigurations."<user>@<hostname>"` entry so `just home` works
3. If the host needs SOPS secrets: get its age public key (`ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`), add it to `.sops.yaml`, then run `sops updatekeys secrets.yaml`
4. Structure `configuration.nix` using the standard section headers (see below)

## Module Conventions

All modules follow the same pattern:
- Expose a NixOS option (e.g. `options.foo.enable`) so features can be toggled per-host
- Wrap all config in `lib.mkIf cfg.enable { ... }`
- Use `let cfg = config.<namespace>; in` at the top

When adding a new module, wire it into the relevant hosts in `flake.nix`.

Because nixpkgs tracks unstable, upstream options get renamed regularly. Renames surface as `evaluation warning: The option X ... has been renamed to Y` during a rebuild — chase them down rather than leaving them, since the compatibility shims are eventually dropped.

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
# FILESYSTEMS
# ===========================================================
# Extra mounts (local disks, NFS) — omit when there are none

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

### Niri (`desktop.niri.enable`)
The compositor `ares` actually runs. Scrollable-tiling Wayland compositor with Xwayland-satellite, Pipewire audio (PulseAudio + ALSA compat), libinput and dconf. Enable alongside `os.wayland.enable`. The user-level config lives in `modules/home/desktop/niri.nix`, which assembles the KDL fragments under `modules/home/desktop/niri/`.

### Hyprland (`desktop.hyprland.enable`)
Alternative Wayland compositor with UWSM, Pipewire audio (PulseAudio + ALSA compat) and rtkit for realtime scheduling. Currently commented out on `ares` in favour of Niri, but kept working. Enable alongside `os.wayland.enable`.

### ReGreet (`desktop.regreet.enable`)
Graphical greetd greeter, themed with Catppuccin Mocha. Enabling it pulls in greetd. Set `desktop.regreet.output` to pin the greeter to one monitor — that swaps the default cage compositor for a dedicated niri instance, and `desktop.regreet.disableOutputs` lists the monitors it switches off. The module carries an overlay adding GStreamer runtime deps to `pkgs.regreet`; without it a wallpaper makes ReGreet 0.4.0 SIGABRT into a greetd respawn loop (black login screen). Drop the overlay once the nixpkgs pin includes nixpkgs#530302.

Note the upstream option is `services.displayManager.regreet.*` — `programs.regreet.*` is the old, renamed name.

### Wayland (`os.wayland.enable`)
Sets NVIDIA-specific Wayland environment variables (`GBM_BACKEND`, `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME`, `NVD_BACKEND`, `NIXOS_OZONE_WL`). Enable on any host running a Wayland compositor with an NVIDIA GPU.

### Hardware (`modules/hardware/`)
- `bluetooth.enable` — Bluetooth stack and Blueman.
- `hardware.mouse.logitech.enable` — Logitech wireless device support via `programs.solaar.enable`, which also turns on `hardware.logitech.wireless` and installs the package. (`hardware.logitech.wireless.enableGraphical` is the old, renamed name.)
- `hardware.ddc.enable` — DDC/CI monitor control with ddcutil. The user needs the `i2c` group.

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
