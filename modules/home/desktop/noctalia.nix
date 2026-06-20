{ pkgs, ... }:

{
  # noctalia v5: option renamed from programs.noctalia-shell -> programs.noctalia,
  # settings are now TOML, and Catppuccin ships as a builtin theme (the old
  # hand-rolled colorschemes/*.json palette is no longer used).
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    cliphist
    grim
    slurp
    wl-clipboard
    playerctl
    pavucontrol
  ];
}
