{ ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/desktop/fonts.nix
    ../../modules/home/desktop/hyprland.nix
    ../../modules/home/desktop/waybar.nix
    ../../modules/home/services/dunst.nix
    ../../modules/home/apps/terminals/ghostty.nix
    ../../modules/home/apps/social/discord.nix
    ../../modules/home/apps/media/spotify.nix
    ../../modules/home/apps/dev/claude-code.nix
    ../../modules/home/apps/browsers/firefox.nix
    ../../modules/home/apps/editors/vscode.nix
    ../../modules/home/apps/editors/zed.nix
  ];
}
