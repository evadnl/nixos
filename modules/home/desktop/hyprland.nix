{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # package = null tells home-manager not to install Hyprland itself,
    # since the NixOS module (programs.hyprland.enable) already does it.
    package = null;
    portalPackage = null;
    # Export all env vars to systemd/dbus so services see the same environment
    # as the terminal (e.g. PATH, WAYLAND_DISPLAY, etc.)
    systemd.variables = [ "--all" ];
  };

  # Pass home-manager session variables into the UWSM session so they are
  # available from startup (required when programs.hyprland.withUWSM = true).
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  programs.kitty.enable = true; # required for the default Hyprland config

  home.packages = with pkgs; [
    hyprlauncher
    adwaita-icon-theme
  ];
}
