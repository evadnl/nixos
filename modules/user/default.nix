{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.user;
in
{
  options.user = {
    enable = lib.mkEnableOption "primary user configuration";

    name = lib.mkOption {
      type = lib.types.str;
      description = "Username";
    };

    wheel = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Grant sudo access via the wheel group";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional groups for the user";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys authorized for login";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "User-specific packages";
    };

    initialPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Initial plaintext password — change after first login";
    };

    sshPrivateKey = {
      enable = lib.mkEnableOption "SSH private key deployed via SOPS";
    };

    zsh = {
      enable = lib.mkEnableOption "zsh as the default shell";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = lib.mkIf cfg.zsh.enable true;

    users.users.${cfg.name} =
      {
        isNormalUser = true;
        extraGroups = cfg.extraGroups ++ lib.optionals cfg.wheel [ "wheel" ];
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
        packages = cfg.packages;
        shell = lib.mkIf cfg.zsh.enable pkgs.zsh;
      }
      // lib.optionalAttrs (cfg.initialPassword != null) {
        initialPassword = cfg.initialPassword;
      };

    sops.secrets = lib.mkIf cfg.sshPrivateKey.enable {
      ssh_private_key = {
        owner = cfg.name;
        path = "/home/${cfg.name}/.ssh/id_ed25519";
        mode = "0600";
      };
    };
  };
}
