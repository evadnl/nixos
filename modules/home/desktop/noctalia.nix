{ pkgs, ... }:

{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {};
  };

  xdg.configFile."noctalia/colorschemes/Catppuccin-Blue/Catppuccin-Blue.json".text = builtins.toJSON {
    dark = {
      mPrimary = "#89b4fa";
      mOnPrimary = "#11111b";
      mSecondary = "#fab387";
      mOnSecondary = "#11111b";
      mTertiary = "#94e2d5";
      mOnTertiary = "#11111b";
      mError = "#f38ba8";
      mOnError = "#11111b";
      mSurface = "#1e1e2e";
      mOnSurface = "#cdd6f4";
      mSurfaceVariant = "#313244";
      mOnSurfaceVariant = "#a3b4eb";
      mOutline = "#4c4f69";
      mShadow = "#11111b";
      mHover = "#89b4fa";
      mOnHover = "#11111b";
      terminal = {
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
        bright = {
          black = "#585b70";
          red = "#f37799";
          green = "#89d88b";
          yellow = "#ebd391";
          blue = "#74a8fc";
          magenta = "#f2aede";
          cyan = "#6bd7ca";
          white = "#bac2de";
        };
        foreground = "#cdd6f4";
        background = "#1e1e2e";
        selectionFg = "#cdd6f4";
        selectionBg = "#585b70";
        cursorText = "#1e1e2e";
        cursor = "#f5e0dc";
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
