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
flake.nix          # Inputs: nixpkgs (unstable), disko, lanzaboote, sops-nix
secrets.yaml       # SOPS-encrypted secrets (see Secret Management below)
.sops.yaml         # SOPS key configuration
hosts/
  <host>/          # Hardware config + host-specific options
modules/
  common.nix       # Shared packages across hosts
  hyprland.nix     # Wayland compositor, Pipewire audio, greetd login (desktop.hyprland.enable)
  user/
    default.nix    # Primary user configuration (user.enable)
  drivers/
    amd-cpu.nix    # AMD microcode updates (drivers.amdCpu.enable)
    nvidia.nix     # NVIDIA closed-source driver (drivers.nvidia.enable)
  network/
    firewall.nix   # nftables firewall, SSH restricted to trusted subnets (network.firewall.enable)
  security/
    default.nix    # Base hardening: SSH, kernel sysctl, protectKernelImage (security.hardening.profile)
    server.nix     # Server profile: fail2ban, auditd, module blacklist, no sleep
    workstation.nix # Workstation profile: AppArmor
  os/
    locale.nix     # Timezone (Europe/Amsterdam), keyboard (us-intl)
    lanzaboote.nix # Secure Boot module wrapping upstream lanzaboote (os.secureBoot.enable)
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
