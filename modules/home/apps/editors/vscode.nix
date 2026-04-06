{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        anthropic.claude-code
        Google.gemini-cli-vscode-ide-companion
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
      userSettings = {
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "claude.claudePath" = "${pkgs.claude-code}/bin/claude";
        "claudeCode.preferredLocation" = "sidebar";
      };
    };
  };
}
