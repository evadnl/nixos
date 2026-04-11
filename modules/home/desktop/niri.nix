{ pkgs, ... }:

{
  # Replaced by Noctalia Shell's built-in lock screen.
  # programs.swaylock = {
  #   enable = true;
  #   package = pkgs.swaylock-effects;
  #   settings = {
  #     font-size = 24;
  #     indicator-idle-visible = false;
  #     indicator-radius = 100;
  #     indicator-caps-lock = true;
  #     show-failed-attempts = true;
  #     indicator = true;
  #     clock = true;
  #     timestr = "%H:%M";
  #     datestr = "%a, %d/%m/%y";
  #   };
  # };

  # catppuccin.swaylock = {
  #   enable = true;
  #   flavor = "mocha";
  # };

  xdg.configFile = {
    "niri/config.kdl".text = ''
      include "inputs.kdl"
      include "outputs.kdl"
      include "environment-variables.kdl"
      include "autostart.kdl"
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
    # Wallpaper now managed by Noctalia Shell.
    # "niri/autostart-wallpaper.kdl".text = ''
    #   spawn-at-startup "${pkgs.writeShellScript "wallpaper-rotate" (builtins.readFile ./niri/wallpaper-rotate.sh)}"
    # '';
    "niri/keybinds.kdl".source = ./niri/keybinds.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/rules.kdl".source = ./niri/rules.kdl;
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    # Moved to modules/home/desktop/noctalia.nix:
    # pavucontrol
    # playerctl
    # grim
    # slurp
    # wl-clipboard
    # Replaced by Noctalia's wallpaper / lock / idle management:
    # awww
    # swayidle
    # (pkgs.writeShellScriptBin "swaylock-random" ''
    #   wallpaper=$(find "$HOME/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
    #   exec swaylock --image "$wallpaper"
    # '')
  ];
}
