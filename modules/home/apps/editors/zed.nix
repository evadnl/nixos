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
      icon_theme = "Catppuccin Mocha",
      theme = "Catppuccin Mocha (Blur)"
      };
    };
  };
}
