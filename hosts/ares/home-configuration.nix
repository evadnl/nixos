{ ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/desktop/cursor.nix
    ../../modules/home/desktop/fonts.nix
    # ../../modules/home/desktop/hyprland.nix
    ../../modules/home/desktop/waybar.nix
    # ../../modules/home/desktop/hyprlock.nix
    # ../../modules/home/desktop/hypridle.nix
    ../../modules/home/desktop/rofi.nix
    ../../modules/home/desktop/gtk.nix
    ../../modules/home/desktop/niri.nix
    ../../modules/home/services/dunst.nix
    ../../modules/home/apps/terminals/ghostty.nix
    ../../modules/home/apps/social/discord.nix
    ../../modules/home/apps/media/spotify.nix
    ../../modules/home/apps/gaming/default.nix
    ../../modules/home/apps/dev/claude-code.nix
    ../../modules/home/apps/dev/gemini-cli.nix
    ../../modules/home/shell/ssh.nix
    ../../modules/home/shell/zsh.nix
    ../../modules/home/shell/starship.nix
    ../../modules/home/apps/files/nautilus.nix
    ../../modules/home/apps/browsers/firefox.nix
    ../../modules/home/apps/editors/vscode.nix
    ../../modules/home/apps/editors/zed.nix
  ];
}
