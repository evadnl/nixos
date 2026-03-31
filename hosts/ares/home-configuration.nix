{ ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/desktop/fonts.nix
    ../../modules/home/desktop/hyprland.nix
    ../../modules/home/desktop/waybar.nix
    ../../modules/home/apps/terminals/ghostty.nix
    ../../modules/home/apps/browsers/firefox.nix
    ../../modules/home/apps/editors/vscode.nix
  ];
}
