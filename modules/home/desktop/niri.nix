{ pkgs, ... }:

{
  xdg.configFile = {
    "niri/config.kdl".text = ''
      include "inputs.kdl"
      include "outputs.kdl"
      include "environment-variables.kdl"
      include "autostart.kdl"
      include "autostart-wallpaper.kdl"
      include "keybinds.kdl"
      include "layout.kdl"
      include "rules.kdl"

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    '';

    "niri/inputs.kdl".source = ./niri/inputs.kdl;
    "niri/outputs.kdl".source = ./niri/outputs.kdl;
    "niri/environment-variables.kdl".source = ./niri/environment-variables.kdl;
    "niri/autostart.kdl".source = ./niri/autostart.kdl;
    "niri/autostart-wallpaper.kdl".text = ''
      spawn-at-startup "${pkgs.writeShellScript "wallpaper-rotate" (builtins.readFile ./niri/wallpaper-rotate.sh)}"
    '';
    "niri/keybinds.kdl".source = ./niri/keybinds.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/rules.kdl".source = ./niri/rules.kdl;
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    pavucontrol
    playerctl
    swww
    grim
    slurp
    wl-clipboard
  ];
}
