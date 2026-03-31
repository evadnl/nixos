# NixOS Configuration

Personal NixOS flake configuration managing two systems.

## Systems

| Host | Description |
|------|-------------|
| **ares** | Main workstation — AMD Ryzen 7 9800X3D + RTX 5080, Secure Boot via Lanzaboote |
| **nixos-vm** | QEMU virtual machine for testing, headless access via wayvnc |

## Usage

Commands are managed with [just](https://github.com/casey/just). All rebuild commands require an explicit `HOST` argument.

```bash
just switch <host>          # Apply configuration
just test <host>            # Test without making permanent (rolls back on reboot)
just build <host>           # Build without applying (useful for checking errors)
just update <host>          # Update flake inputs and switch
just home <user> <host>     # Apply home-manager config only (faster, no sudo)
just clean                  # Remove generations older than 7 days and garbage collect
just clean <days>           # Remove generations older than N days
just fmt                    # Format all Nix files
just secrets                # Edit SOPS secrets
just update-keys            # Re-encrypt secrets after adding a host to .sops.yaml
just host-key               # Print this machine's age public key (run on the new host)
```

## Structure

```
flake.nix          # Inputs: nixpkgs (unstable), disko, lanzaboote, sops-nix, home-manager
secrets.yaml       # SOPS-encrypted secrets (see Secret Management below)
.sops.yaml         # SOPS key configuration
hosts/
  <host>/
    configuration.nix        # NixOS system config
    home-configuration.nix   # Home-manager app selection for this host
modules/
  common.nix       # Shared packages across hosts
  home/
    default.nix    # NixOS module: wires home-manager into the system for each host
    base.nix       # Pure HM module: stateVersion, home-manager CLI
    apps/
      browsers/    # Browser app modules (e.g. firefox.nix)
      editors/     # Editor app modules (e.g. vscode.nix)
  desktop/
    hyprland.nix   # Wayland compositor (UWSM), Pipewire audio, greetd/tuigreet login (desktop.hyprland.enable)
  user/
    default.nix    # Primary user configuration (user.enable)
  drivers/
    amd-cpu.nix    # AMD microcode updates (drivers.amdCpu.enable)
    nvidia.nix     # NVIDIA driver, modesetting, hardware graphics (drivers.nvidia.enable)
  network/
    firewall.nix   # nftables firewall, SSH restricted to trusted subnets (network.firewall.enable)
  security/
    default.nix    # Base hardening: SSH, kernel sysctl, protectKernelImage (security.hardening.profile)
    server.nix     # Server profile: fail2ban, auditd, module blacklist, no sleep
    workstation.nix # Workstation profile: AppArmor
  os/
    locale.nix     # Timezone (Europe/Amsterdam), keyboard (us-intl)
    lanzaboote.nix # Secure Boot module wrapping upstream lanzaboote (os.secureBoot.enable)
    wayland.nix    # NVIDIA Wayland env vars: GBM, LIBVA, OZONE_WL (os.wayland.enable)
```

## Host Configuration Structure

Each host's `configuration.nix` follows a consistent section layout using comment headers:

```nix
# ===========================================================
# SYSTEM
# ===========================================================
# Boot loader, stateVersion, nix settings, unfree packages,
# and system-wide security profile.

# ===========================================================
# HARDWARE
# ===========================================================
# Host-specific hardware modules: drivers, secure boot.

# ===========================================================
# DESKTOP
# ===========================================================
# Display environment (Hyprland). Omit on headless hosts.

# ===========================================================
# USER
# ===========================================================
# Primary user configuration and SOPS secrets.

# ===========================================================
# NETWORKING
# ===========================================================
# Hostname, networkmanager, firewall.

# ===========================================================
# SERVICES
# ===========================================================
# System services such as OpenSSH.

# ===========================================================
# PACKAGES
# ===========================================================
# Host-specific system packages.
```

Not every section is required — omit sections that don't apply to the host (e.g. no DESKTOP on a server, no HARDWARE if no special drivers are needed).

## Updating Packages

Flake inputs (nixpkgs, etc.) are pinned in `flake.lock`. To update them:

```bash
# Update all inputs
nix flake update

# Or update a single input
nix flake update nixpkgs

# Then apply
sudo nixos-rebuild switch --flake .#ares

# Commit the updated lock file
git add flake.lock
git commit -m "flake: update inputs"
```

`nixos-rebuild switch` reads `flake.lock` as-is and will not modify it — only `nix flake update` changes the lock file.

## Secure Boot (ares only)

Lanzaboote is used for Secure Boot. Initial key enrollment:

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys
```

## Secret Management

Secrets (SSH keys, passwords, etc.) are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using [age](https://age-encryption.org/) keys. Each host decrypts its own secrets at activation time using its SSH host key.

### Adding a new host

**1. Get the host's age public key** (run on the host):
```bash
nix-shell -p ssh-to-age --run "ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub"
```

**2. Add it to `.sops.yaml`:**
```yaml
keys:
  - &my-host age1abc123...

creation_rules:
  - path_regex: secrets\.yaml$
    key_groups:
      - age:
          - *my-host
```

**3. Re-encrypt `secrets.yaml` for the new host:**
```bash
sops updatekeys secrets.yaml
```

**4. Tell NixOS where to find the age key** (in the host's configuration):
```nix
sops.defaultSopsFile = ../../secrets.yaml;
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

### Editing secrets

```bash
sops secrets.yaml
```

Opens your editor with the decrypted content. Saving re-encrypts automatically.

### Editing from a dev machine

Generate a personal age key and add its public key to `.sops.yaml`, then re-encrypt:
```bash
age-keygen -o ~/.config/sops/age/keys.txt  # one-time setup
sops updatekeys secrets.yaml
```

## User Module

The `modules/user/default.nix` module provides a declarative way to configure the primary user per host via `user.*` options.

### Options

| Option | Type | Description |
|--------|------|-------------|
| `user.enable` | bool | Enable the module |
| `user.name` | string | Username |
| `user.wheel` | bool | Grant sudo access via the wheel group |
| `user.extraGroups` | list | Additional groups |
| `user.authorizedKeys` | list | SSH public keys allowed to log in |
| `user.packages` | list | User-specific packages |
| `user.initialPassword` | string | Plaintext password — change after first login |
| `user.sshPrivateKey.enable` | bool | Deploy an SSH private key from SOPS secrets |

### Authorized keys

Keys listed in `user.authorizedKeys` are **not** placed in `~/.ssh/authorized_keys`. NixOS manages them at `/etc/ssh/authorized_keys.d/<username>`, which OpenSSH reads via the `AuthorizedKeysFile` directive. This means the file is owned by root and cannot be accidentally overwritten by the user.

### SSH private key

When `user.sshPrivateKey.enable = true`, the secret `ssh_private_key` from `secrets.yaml` is decrypted at activation time and stored in `/run/secrets/ssh_private_key`. The path `/home/<user>/.ssh/id_ed25519` is a symlink pointing there, with mode `0600` and owned by the user.

## Home Manager

User applications are managed with [home-manager](https://github.com/nix-community/home-manager), keeping user-level software (browsers, editors, dotfiles) separate from system packages.

### Structure

Each host has its own home-manager config file alongside its NixOS config:

```
hosts/
  ares/
    configuration.nix        # NixOS system config
    home-configuration.nix   # Home-manager config for this host
modules/home/
  default.nix                # NixOS module: wires home-manager into the system
  base.nix                   # Pure HM module: stateVersion, home-manager CLI
  desktop/
    hyprland.nix             # HM module: Hyprland config, UWSM env, packages
    waybar.nix               # HM module: Waybar bar config
    fonts.nix                # HM module: font packages (Font Awesome, etc.)
  apps/
    browsers/
      firefox.nix            # Pure HM module
    editors/
      vscode.nix             # Pure HM module
```

`hosts/<host>/home-configuration.nix` is the single place to manage which apps a host gets. It imports from `modules/home/apps/` as needed.

### Adding an app to a host

Edit the host's `home-configuration.nix` and add the import:

```nix
{ ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/apps/browsers/firefox.nix
    ../../modules/home/apps/editors/vscode.nix  # ← add this
  ];
}
```

### Creating a new app module

Create a file under `modules/home/apps/<category>/<app>.nix`. These are pure home-manager modules — no NixOS wrapper needed:

```nix
{ ... }:

{
  programs.<app>.enable = true;
}
```

Then import it in the relevant host's `home-configuration.nix`.

### Configuring an app

All home-manager `programs.*` options are available directly in the app module. See the [home-manager option search](https://home-manager-options.extid.eu/) for what's available.

**Example — Firefox with extensions:**

```nix
{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      extensions.packages = with pkgs.firefox-addons; [
        ublock-origin
        bitwarden
      ];
      settings = {
        "browser.startup.homepage" = "about:blank";
      };
    };
  };
}
```

**Example — VS Code with extensions:**

```nix
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
    userSettings = {
      "editor.fontSize" = 14;
      "editor.formatOnSave" = true;
    };
  };
}
```

### Applying changes

For a full system rebuild (required when adding new packages):

```bash
just switch <host>
```

For home-manager config changes only (faster — no sudo, no full rebuild):

```bash
just home <user> <host>
```

## Security Hardening

The `modules/security/` modules provide system hardening via a single `security.hardening.profile` option. Set it in the SYSTEM section of the host's `configuration.nix`:

```nix
security.hardening.profile = "workstation"; # or "server"
```

### Base hardening (both profiles)

Always applied when a profile is set.

| What | Why |
|------|-----|
| SSH: disable root login, password auth, X11 forwarding | Reduce SSH attack surface to key-based auth only |
| SSH: `LoginGraceTime = 30`, `MaxAuthTries = 3` | Limit brute force window |
| SSH: disable agent and TCP forwarding | Prevent tunneling through the host |
| `security.protectKernelImage = true` | Block writes to `/dev/mem` and kernel image modification |
| `security.sudo.execWheelOnly = true` | Prevent arbitrary scripts from being run via sudo |
| `kernel.kptr_restrict = 2` | Hide kernel pointers from unprivileged users |
| `kernel.dmesg_restrict = 1` | Restrict kernel log to privileged users |
| `kernel.yama.ptrace_scope = 1` | Restrict ptrace to parent processes (limits debugger attach) |
| `net.ipv4.tcp_syncookies = 1` | SYN flood protection |
| Disable ICMP redirects (send + accept) | Prevent route hijacking via ICMP |
| Reverse path filtering | Drop packets with spoofed source addresses |

### Workstation profile

```nix
security.hardening.profile = "workstation";
```

| What | Why |
|------|-----|
| `security.apparmor.enable = true` | Mandatory access control — confines programs to predefined profiles. Even if an application is exploited, it cannot access resources outside its profile. |

### Server profile

```nix
security.hardening.profile = "server";
```

| What | Why |
|------|-----|
| `fail2ban` | Bans IPs after 5 failed SSH attempts. Ban time doubles with each repeat offence, capped at 1 week. |
| `security.auditd` | Kernel-level audit log for tracking security-relevant events |
| Disable sleep/suspend/hibernate targets | Servers should never sleep — prevents accidental downtime |
| Blacklist `usb-storage`, `firewire-core`, `thunderbolt` | Reduce attack surface for physical access attacks on headless servers |

## MCP Server

This repo includes an `.mcp.json` that configures the [mcp-nixos](https://github.com/utensils/mcp-nixos) server for use with Claude Code. It allows querying NixOS options, packages, and documentation directly from the editor.

> **Prerequisite:** The [Nix package manager](https://nixos.org/download/) must be installed on your machine, as the MCP server is run via `nix run`.
