{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.hyprland;

  sddm-wallpaper = "/var/lib/sddm/wallpaper";

  sddm-theme = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
    font = "JetBrainsMono Nerd Font Propo";
    fontSize = "10";
    background = sddm-wallpaper;
    loginBackground = true;
  };
in
{
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;
    };

    services.libinput.enable = true;

    # --- SDDM display manager ---
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
        theme = "${sddm-theme}/share/sddm/themes/catppuccin-mocha-mauve";
        package = pkgs.kdePackages.sddm;
        settings.Theme = {
          CursorTheme = "catppuccin-mocha-dark-cursors";
          CursorSize = 24;
        };
        extraPackages = [ pkgs.catppuccin-cursors.mochaDark ];
      };
      defaultSession = "hyprland-uwsm";
    };

    environment.systemPackages = [ sddm-theme ];

    # Copy a random wallpaper to a system-wide path readable by SDDM
    systemd.services.sddm-wallpaper-sync = {
      description = "Pick random wallpaper for SDDM greeter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "sddm-wallpaper-sync" ''
          dest="${sddm-wallpaper}"
          wallpaper=$(find "/home/${config.user.name}/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1)
          [ -n "$wallpaper" ] && cp "$wallpaper" "$dest" && chmod 644 "$dest"
        '';
      };
    };

  };
}
