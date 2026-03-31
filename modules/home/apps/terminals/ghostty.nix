{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "Catppuccin Mocha";
      background-opacity = 0.9;
      background-blur = 10;
      quick-terminal-animation-duration = 0;

      keybind = [
        performable:ctrl+c=copy_to_clipboard
        performable:ctrl+v=paste_from_clipboard
      ];
    };
  };
}
