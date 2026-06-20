{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.regreet;

  regreet-wallpaper = "/var/lib/regreet/wallpaper";

  # Greeter-only niri config: keep just the chosen output enabled (others off)
  # so ReGreet lands on a single screen instead of being centred across the
  # multi-monitor layout. Launches regreet, then quits niri once login starts.
  greeterConfig = pkgs.writeText "niri-greeter.kdl" ''
    ${lib.concatMapStringsSep "\n" (o: ''output "${o}" { off; }'') cfg.disableOutputs}

    output "${cfg.output}" {
        transform "normal"
    }

    hotkey-overlay {
        skip-at-startup
    }

    spawn-at-startup "sh" "-c" "${lib.getExe config.programs.regreet.package}; ${lib.getExe config.programs.niri.package} msg action quit --skip-confirmation"
  '';
in
{
  options.desktop.regreet = {
    enable = lib.mkEnableOption "ReGreet display greeter";

    output = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "HDMI-A-2";
      description = ''
        Run the greeter inside a dedicated niri instance pinned to this output
        (e.g. "HDMI-A-2") instead of cage. Leave null to use the default cage
        compositor, which spans all monitors and centres the greeter on the seam.
      '';
    };

    disableOutputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "DP-2" "HDMI-A-1" ];
      description = ''
        Outputs to switch off in the greeter so the greeter only shows on
        `output`. Only used when `output` is set.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # ReGreet 0.4.0 routes any wallpaper through GStreamer (GTK media file), but
    # the nixpkgs package omits the GStreamer runtime deps, so it SIGABRTs at
    # launch whenever a wallpaper is set -> greetd respawn loop -> black login
    # screen (upstream ReGreet#165). Replicates nixpkgs#530302 (merged to master
    # 2026-06-16, not yet in the nixos-unstable channel). Drop once our nixpkgs
    # pin includes that fix.
    nixpkgs.overlays = [
      (final: prev: {
        regreet = prev.regreet.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ (with final.gst_all_1; [
            gstreamer
            gst-plugins-base
            gst-plugins-good
          ]);
        });
      })
    ];

    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = regreet-wallpaper;
          fit = "Cover";
        };
        GTK = {
          cursor_theme_name = "catppuccin-mocha-dark-cursors";
          font_name = "JetBrainsMono Nerd Font Propo 10";
          icon_theme_name = "Adwaita";
          theme_name = "catppuccin-mocha-mauve-standard";
        };
      };
      cursorTheme = {
        package = pkgs.catppuccin-cursors.mochaDark;
        name = "catppuccin-mocha-dark-cursors";
      };
      font = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Propo";
        size = 10;
      };
      theme = {
        package = pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "mauve" ];
        };
        name = "catppuccin-mocha-mauve-standard";
      };
    };

    # When an output is chosen, drive the greeter with niri (pinned to that
    # output) rather than the default cage compositor.
    services.greetd.settings.default_session.command = lib.mkIf (cfg.output != null) (
      "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe config.programs.niri.package} -c ${greeterConfig}"
    );

    # Copy a random wallpaper to a system-wide path readable by ReGreet
    systemd.services.regreet-wallpaper-sync = {
      description = "Pick random wallpaper for ReGreet greeter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "regreet-wallpaper-sync" ''
          dest="${regreet-wallpaper}"
          mkdir -p "$(dirname "$dest")"
          wallpaper=$(find "/home/${config.user.name}/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1)
          [ -n "$wallpaper" ] && cp "$wallpaper" "$dest" && chmod 644 "$dest"
        '';
      };
    };
  };
}
