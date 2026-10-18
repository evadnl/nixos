{ config, pkgs, lib, ... }:

let
  hyper = "Ctrl+Alt+Shift+Meta";

  autostart = name: exec: {
    "autostart/${name}.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=${name}
      Exec=${exec}
      X-KDE-autostart-phase=2
    '';
  };

  place = href: title: icon: ''
    <bookmark href="${href}">
     <title>${title}</title>
     <info>
      <metadata owner="http://freedesktop.org">
       <bookmark:icon name="${icon}"/>
      </metadata>
     </info>
    </bookmark>
  '';

  dolphinPlaces = pkgs.writeText "user-places.xbel" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE xbel>
    <xbel xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info" xmlns:kdepriv="http://www.kde.org/kdepriv">
    ${place "file://${config.home.homeDirectory}" "Home" "user-home"}
    ${place "file:///mnt/games1" "Games" "drive-harddisk"}
    ${place "file:///mnt/nas/downloads" "NAS Downloads" "folder-network"}
    ${place "file:///mnt/nas/fotos" "NAS Fotos" "folder-network"}
    </xbel>
  '';

  desktopNumbers = lib.range 1 9;
in
{
  home.packages = with pkgs; [
    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
    })
    (catppuccin-gtk.override {
      accents = [ "mauve" ];
      variant = "mocha";
    })
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "mauve";
    })
    catppuccin-cursors.mochaDark
  ];

  programs.plasma = {
    enable = true;

    input.keyboard.layouts = [
      {
        layout = "us";
        variant = "intl";
      }
    ];

    kwin.virtualDesktops = {
      number = 9;
      rows = 1;
    };

    krunner.shortcuts.launch = [ "Meta+Space" "Alt+Space" ];

    spectacle.shortcuts = {
      captureRectangularRegion = "Print";
      captureEntireDesktop = "Ctrl+Print";
    };

    hotkeys.commands = {
      ghostty = {
        name = "Ghostty";
        keys = [ "Meta+Return" "${hyper}+Return" ];
        command = "ghostty";
      };
      ghostty-float = {
        name = "Ghostty (floating)";
        key = "Meta+Ctrl+Return";
        command = "ghostty --class=com.mitchellh.ghostty-float";
      };
      browser = {
        name = "Browser";
        keys = [ "Meta+B" "${hyper}+B" ];
        command = "firefox";
      };
      code = {
        name = "VS Code";
        key = "${hyper}+C";
        command = "code";
      };
    };

    shortcuts = {
      kwin = {
        "Window Close" = [ "Alt+F4" "Meta+W" ];
        "Overview" = "Meta+O";
        "Window Maximize" = "Meta+F";
        "Window Fullscreen" = "Meta+Shift+F";
        "Window Minimize" = [ ];
        "Window Move Center" = "Meta+C";

        "Switch Window Left" = [ "Meta+H" "Meta+Left" ];
        "Switch Window Down" = [ "Meta+J" "Meta+Down" ];
        "Switch Window Up" = [ "Meta+K" "Meta+Up" ];
        "Switch Window Right" = [ "Meta+L" "Meta+Right" ];
        "Window Quick Tile Left" = [ ];
        "Window Quick Tile Right" = [ ];
        "Window Quick Tile Top" = [ ];
        "Window Quick Tile Bottom" = [ ];

        "Switch One Desktop to the Left" = [ ];
        "Switch One Desktop to the Right" = [ ];
        "Switch One Desktop Up" = [ ];
        "Switch One Desktop Down" = [ ];
        "Window Pack Left" = [ "Meta+Ctrl+H" "Meta+Ctrl+Left" ];
        "Window Pack Down" = [ "Meta+Ctrl+J" "Meta+Ctrl+Down" ];
        "Window Pack Up" = [ "Meta+Ctrl+K" "Meta+Ctrl+Up" ];
        "Window Pack Right" = [ "Meta+Ctrl+L" "Meta+Ctrl+Right" ];

        "Switch to Screen to the Left" = [ "Meta+Shift+H" "Meta+Shift+Left" ];
        "Switch to Screen Below" = [ "Meta+Shift+J" "Meta+Shift+Down" ];
        "Switch to Screen Above" = [ "Meta+Shift+K" "Meta+Shift+Up" ];
        "Switch to Screen to the Right" = [ "Meta+Shift+L" "Meta+Shift+Right" ];
        "Window to Previous Screen" = [ ];
        "Window to Next Screen" = [ ];

        "Window One Screen to the Left" = [ "Meta+Shift+Ctrl+H" "Meta+Shift+Ctrl+Left" ];
        "Window One Screen Down" = [ "Meta+Shift+Ctrl+J" "Meta+Shift+Ctrl+Down" ];
        "Window One Screen Up" = [ "Meta+Shift+Ctrl+K" "Meta+Shift+Ctrl+Up" ];
        "Window One Screen to the Right" = [ "Meta+Shift+Ctrl+L" "Meta+Shift+Ctrl+Right" ];

        "Switch to Next Desktop" = [ "Meta+U" "Meta+PgDown" ];
        "Switch to Previous Desktop" = [ "Meta+I" "Meta+PgUp" ];
        "Window to Next Desktop" = [ "Meta+Ctrl+U" "Meta+Ctrl+PgDown" ];
        "Window to Previous Desktop" = [ "Meta+Ctrl+I" "Meta+Ctrl+PgUp" ];
      }
      // lib.listToAttrs (
        lib.concatMap (n: [
          (lib.nameValuePair "Switch to Desktop ${toString n}" "Meta+${toString n}")
          (lib.nameValuePair "Window to Desktop ${toString n}" "Meta+Ctrl+${toString n}")
        ]) desktopNumbers
      );

      plasmashell = lib.listToAttrs (
        map (n: lib.nameValuePair "activate task manager entry ${toString n}" [ ]) desktopNumbers
      );

      ksmserver = {
        "Lock Session" = [ "Meta+Alt+L" "Screensaver" ];
        "Log Out" = [ "Ctrl+Alt+Del" "Meta+Shift+E" ];
      };
    };

    configFile = {
      kwinrc.Plugins.rectangleEnabled = true;
    };
  };

  xdg.dataFile."kwin/scripts/rectangle".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/home/desktop/plasma/rectangle";
  xdg.dataFile."plasma/plasmoids/nl.evad.powermenu".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/home/desktop/plasma/powermenu";

  xdg.configFile =
    {
      "systemd/user/kde-baloo.service.d/offscreen.conf".text = ''
        [Service]
        Environment=QT_QPA_PLATFORM=offscreen
      '';
    }
    // autostart "vesktop" "vesktop"
    // autostart "1password" "1password --silent"
    // autostart "steam" "steam -silent -pipewire";

  home.activation.dolphinPlaces = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    places="${config.xdg.dataHome}/user-places.xbel"
    if [ ! -e "$places" ]; then
      run install -Dm644 ${dolphinPlaces} "$places"
    fi
  '';
}
