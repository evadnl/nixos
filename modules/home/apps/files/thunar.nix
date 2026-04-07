{ ... }:

{
  # Bookmarks: home + mounted disks
  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///home/evad Home
    file:///mnt/games1 Games
    file:///mnt/nas/downloads NAS Downloads
    file:///mnt/nas/fotos NAS Fotos
  '';

  xfconf.settings = {
    xsettings = {
      "Net/ThemeName" = "catppuccin-mocha-mauve-standard";
      "Net/IconThemeName" = "Papirus-Dark";
      "Gtk/CursorThemeName" = "catppuccin-mocha-dark-cursors";
      "Gtk/ApplicationPreferDarkTheme" = 1;
    };
    thunar = {
      "last-side-pane" = "ThunarShortcutsPane";
      "misc-show-delete-action" = true;
      "misc-volume-management" = true;
      "misc-thumbnail-mode" = "THUNAR_THUMBNAIL_MODE_ALWAYS";
    };
  };
}
