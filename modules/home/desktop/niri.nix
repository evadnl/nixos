{ pkgs, lib, ... }:

let
  # Mirror the ASUS onto the GSV capture card. wl-mirror can only name the source
  # output by connector, and niri assigns connector names (HDMI-A-1/HDMI-A-2) in an
  # unstable order across cold boots, so resolve the ASUS's current connector from
  # `niri msg outputs` — matched on its model (PG34WCDN), which is stable — and
  # mirror that. The window is placed on the capture card by the open-on-output rule
  # in niri/rules.kdl (matched by the card's EDID, also connector-independent).
  mirrorAsus = pkgs.writeShellScript "wl-mirror-asus" ''
    conn=""
    for _ in $(${pkgs.coreutils}/bin/seq 1 20); do
      conn=$(${lib.getExe' pkgs.niri "niri"} msg outputs \
        | ${pkgs.gawk}/bin/awk -F'[()]' '/PG34WCDN/ { print $2; exit }')
      [ -n "$conn" ] && break
      ${pkgs.coreutils}/bin/sleep 0.5
    done
    if [ -z "$conn" ]; then
      echo "wl-mirror-asus: ASUS PG34WCDN not found in niri outputs" >&2
      exit 1
    fi
    exec ${lib.getExe' pkgs.wl-mirror "wl-mirror"} "$conn"
  '';
in
{
  # Replaced by Noctalia Shell's built-in lock screen.
  # programs.swaylock = {
  #   enable = true;
  #   package = pkgs.swaylock-effects;
  #   settings = {
  #     font-size = 24;
  #     indicator-idle-visible = false;
  #     indicator-radius = 100;
  #     indicator-caps-lock = true;
  #     show-failed-attempts = true;
  #     indicator = true;
  #     clock = true;
  #     timestr = "%H:%M";
  #     datestr = "%a, %d/%m/%y";
  #   };
  # };

  # catppuccin.swaylock = {
  #   enable = true;
  #   flavor = "mocha";
  # };

  xdg.configFile = {
    "niri/config.kdl".text = ''
      include "inputs.kdl"
      include "outputs.kdl"
      include "environment-variables.kdl"
      include "autostart.kdl"
      include "keybinds.kdl"
      include "layout.kdl"
      include "rules.kdl"

      // Mirror the ASUS onto the capture card. Kept here (not in autostart.kdl) so
      // it can resolve the ASUS's connector at launch — see wl-mirror-asus above.
      spawn-at-startup "${mirrorAsus}"

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    '';

    "niri/inputs.kdl".source = ./niri/inputs.kdl;
    "niri/outputs.kdl".source = ./niri/outputs.kdl;
    "niri/environment-variables.kdl".source = ./niri/environment-variables.kdl;
    "niri/autostart.kdl".source = ./niri/autostart.kdl;
    # Wallpaper now managed by Noctalia Shell.
    # "niri/autostart-wallpaper.kdl".text = ''
    #   spawn-at-startup "${pkgs.writeShellScript "wallpaper-rotate" (builtins.readFile ./niri/wallpaper-rotate.sh)}"
    # '';
    "niri/keybinds.kdl".source = ./niri/keybinds.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/rules.kdl".source = ./niri/rules.kdl;
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    wl-mirror
    # Moved to modules/home/desktop/noctalia.nix:
    # pavucontrol
    # playerctl
    # grim
    # slurp
    # wl-clipboard
    # Replaced by Noctalia's wallpaper / lock / idle management:
    # awww
    # swayidle
    # (pkgs.writeShellScriptBin "swaylock-random" ''
    #   wallpaper=$(find "$HOME/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
    #   exec swaylock --image "$wallpaper"
    # '')
  ];
}
