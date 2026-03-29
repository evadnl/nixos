# Apply configuration to the target host
switch host:
    sudo nixos-rebuild switch --flake .#{{host}}

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
