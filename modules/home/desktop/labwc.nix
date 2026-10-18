{ config, pkgs, lib, ... }:

let
  themeName = "catppuccin-mocha-traffic";

  mirrorAsus = pkgs.writeShellScript "wl-mirror-asus" ''
    asus=""
    gsv=""
    for _ in $(${pkgs.coreutils}/bin/seq 1 20); do
      outputs=$(${lib.getExe pkgs.wlr-randr} --json)
      asus=$(${lib.getExe pkgs.jq} -r '.[] | select(.enabled and .model == "PG34WCDN") | .name' <<<"$outputs")
      gsv=$(${lib.getExe pkgs.jq} -r '.[] | select(.enabled and .make == "GSV") | .name' <<<"$outputs")
      [ -n "$asus" ] && [ -n "$gsv" ] && break
      ${pkgs.coreutils}/bin/sleep 0.5
    done
    if [ -z "$asus" ] || [ -z "$gsv" ]; then
      echo "wl-mirror-asus: ASUS PG34WCDN or GSV capture card not found in wlr-randr" >&2
      exit 1
    fi
    exec ${lib.getExe' pkgs.wl-mirror "wl-mirror"} --fullscreen-output "$gsv" "$asus"
  '';

  buttonColors = {
    close = "#f38ba8";
    iconify = "#f9e2af";
    max = "#a6e3a1";
    max_toggled = "#a6e3a1";
  };

  buttonGlyphs = {
    close = ''<path d="M5.5 5.5l5 5M10.5 5.5l-5 5"/>'';
    iconify = ''<path d="M5 8h6"/>'';
    max = ''<path d="M8 5v6M5 8h6"/>'';
    max_toggled = ''<path d="M5 8h6"/>'';
  };

  button = color: glyph: ''
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
      <circle cx="8" cy="8" r="6" fill="${color}"/>
      <g stroke="#1e1e2e" stroke-width="1.5" stroke-linecap="round">${glyph}</g>
    </svg>
  '';

  buttonFiles = lib.concatMapAttrs (
    name: color:
    let
      file = suffix: "themes/${themeName}/labwc/${name}${suffix}.svg";
    in
    {
      ${file "-active"}.text = button color "";
      ${file "-inactive"}.text = button "#45475a" "";
      ${file "_hover-active"}.text = button color buttonGlyphs.${name};
      ${file "_hover-inactive"}.text = button color buttonGlyphs.${name};
    }
  ) buttonColors;
in
{
  wayland.windowManager.labwc = {
    enable = true;
    package = null;
    systemd.enable = false;

    autostart = [
      "uwsm finalize"
      "${lib.getExe pkgs.kanshi} --config ${config.xdg.configHome}/labwc/kanshi >/dev/null 2>&1 &"
      "noctalia >/dev/null 2>&1 &"
      "blueman-applet >/dev/null 2>&1 &"
      "vesktop >/dev/null 2>&1 &"
      "1password --silent >/dev/null 2>&1 &"
      "steam -silent -pipewire >/dev/null 2>&1 &"
      "${mirrorAsus} >/dev/null 2>&1 &"
    ];
  };

  xdg.configFile = {
    "labwc/rc.xml".source = ./labwc/rc.xml;
    "labwc/kanshi".source = ./labwc/kanshi;
    "uwsm/env-labwc".source = ./labwc/env;
  };

  xdg.dataFile = buttonFiles // {
    "themes/${themeName}/labwc/themerc".source = ./labwc/themerc;
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    wl-mirror
    wlr-randr
  ];
}
