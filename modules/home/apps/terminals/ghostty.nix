{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "Catppuccin Mocha";
      background-opacity = 0.9;
      background-blur = false;

      window-decoration = false;

      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "performable:ctrl+v=paste_from_clipboard"
        "super+d=new_split:right"
        "super+shift+d=new_split:down"
      ];
    };
  };
}
