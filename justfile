# Apply home-manager configuration for a user@host (faster than full rebuild for HM-only changes)
home user host:
    home-manager switch --flake .#{{user}}@{{host}}

# Apply configuration to the target host
switch host:
    sudo nixos-rebuild switch --flake .#{{host}}
    pkill -x hyprlauncher || true # restart so it picks up newly installed .desktop files

# Test configuration without making it permanent (rolls back on reboot)
test host:
    sudo nixos-rebuild test --flake .#{{host}}

# Build configuration without applying (useful for checking errors)
build host:
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Update all flake inputs and switch to the new configuration
update host:
    nix flake update
    sudo nixos-rebuild switch --flake .#{{host}}

# Remove generations older than N days and garbage collect (default: 7)
clean days="7":
    sudo nix-collect-garbage --delete-older-than {{days}}d
    sudo /run/current-system/bin/switch-to-configuration boot

# Format all Nix files
fmt:
    nixfmt **/*.nix

# Edit SOPS secrets
secrets:
    sops secrets.yaml

# Re-encrypt secrets.yaml after adding a new host to .sops.yaml
update-keys:
    sops updatekeys secrets.yaml

# Print the age public key for this machine (run on the new host)
host-key:
    nix run nixpkgs#ssh-to-age -- < /etc/ssh/ssh_host_ed25519_key.pub
