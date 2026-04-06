{ pkgs, ... }:

{
  catppuccin.rofi = {
    enable = true;
    flavor = "mocha";
  };

  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font Propo 12";
    terminal = "ghostty";
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun = " Apps";
    };
  };
}
