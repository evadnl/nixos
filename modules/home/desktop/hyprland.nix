{ config, pkgs, lib, ... }:

let
  mirrorAsus = pkgs.writeShellScript "wl-mirror-asus" ''
    conn=""
    for _ in $(${pkgs.coreutils}/bin/seq 1 20); do
      conn=$(hyprctl monitors -j \
        | ${lib.getExe pkgs.jq} -r '.[] | select(.description | startswith("ASUSTek COMPUTER INC PG34WCDN")) | .name')
      [ -n "$conn" ] && break
      ${pkgs.coreutils}/bin/sleep 0.5
    done
    if [ -z "$conn" ]; then
      echo "wl-mirror-asus: ASUS PG34WCDN not found in hyprctl monitors" >&2
      exit 1
    fi
    exec ${lib.getExe' pkgs.wl-mirror "wl-mirror"} "$conn"
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    systemd.enable = false;

    extraLuaFiles = {
      monitors = ./hyprland/monitors.lua;
      input = ./hyprland/input.lua;
      environment = ./hyprland/environment.lua;
      autostart = ./hyprland/autostart.lua;
      look = ./hyprland/look.lua;
      keybinds = ./hyprland/keybinds.lua;
      rules = ./hyprland/rules.lua;
    };

    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("${mirrorAsus}")
      end)
    '';
  };

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.pointerCursor.hyprcursor.enable = true;

  home.packages = with pkgs; [
    adwaita-icon-theme
    wl-mirror
  ];
}
