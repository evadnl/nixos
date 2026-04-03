{ pkgs, ... }:

let
  catppuccin-gtk = pkgs.catppuccin-gtk.override {
    accents = [ "mauve" ];
    variant = "mocha";
  };
in
{
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard+default";
      package = catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # GTK4/libadwaita apps (like Nautilus) don't read gtk.theme —
  # they need the stylesheet in ~/.config/gtk-4.0/
  xdg.configFile."gtk-4.0/assets".source =
    "${catppuccin-gtk}/share/themes/catppuccin-mocha-mauve-standard+default/gtk-4.0/assets";
  xdg.configFile."gtk-4.0/gtk.css".source =
    "${catppuccin-gtk}/share/themes/catppuccin-mocha-mauve-standard+default/gtk-4.0/gtk.css";
  xdg.configFile."gtk-4.0/gtk-dark.css".source =
    "${catppuccin-gtk}/share/themes/catppuccin-mocha-mauve-standard+default/gtk-4.0/gtk-dark.css";

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "catppuccin-mocha-mauve-standard+default";
    icon-theme = "Papirus-Dark";
  };
}
