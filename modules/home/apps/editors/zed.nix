{ ... }:

{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "claude-code"
      "catppuccin-blur"
      "catppuccin-icons"
    ];
    userSettings = {
      theme = {
        mode = "dark";
        dark = "Catppuccin Mocha Blur";
      };
      icon_theme = "Catppuccin Mocha";
      theme" = "Catppuccin Mocha (Blur)";
    };
  };
}
