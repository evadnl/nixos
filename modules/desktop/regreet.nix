{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.regreet;

  regreet-wallpaper = "/var/lib/regreet/wallpaper";
in
{
  options.desktop.regreet = {
    enable = lib.mkEnableOption "ReGreet display greeter";
  };

  config = lib.mkIf cfg.enable {
    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = regreet-wallpaper;
          fit = "Cover";
        };
        GTK = {
          cursor_theme_name = "catppuccin-mocha-dark-cursors";
          font_name = "JetBrainsMono Nerd Font Propo 10";
          icon_theme_name = "Adwaita";
          theme_name = "catppuccin-mocha-mauve-standard";
        };
      };
      cursorTheme = {
        package = pkgs.catppuccin-cursors.mochaDark;
        name = "catppuccin-mocha-dark-cursors";
      };
      font = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Propo";
        size = 10;
      };
      theme = {
        package = pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "mauve" ];
        };
        name = "catppuccin-mocha-mauve-standard";
      };
    };

    # Copy a random wallpaper to a system-wide path readable by ReGreet
    systemd.services.regreet-wallpaper-sync = {
      description = "Pick random wallpaper for ReGreet greeter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "regreet-wallpaper-sync" ''
          dest="${regreet-wallpaper}"
          mkdir -p "$(dirname "$dest")"
          wallpaper=$(find "/home/${config.user.name}/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1)
          [ -n "$wallpaper" ] && cp "$wallpaper" "$dest" && chmod 644 "$dest"
        '';
      };
    };
  };
}
