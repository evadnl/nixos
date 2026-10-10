{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.regreet;

  regreet-wallpaper = "/var/lib/regreet/wallpaper";

  monitorDesc = o: "desc:${builtins.head (lib.splitString "  " o)}";

  # Greeter-only Hyprland config: keep just the chosen output enabled (others off)
  # so ReGreet lands on a single screen instead of being centred across the
  # multi-monitor layout. Launches regreet, then quits Hyprland once login starts.
  greeterConfig = pkgs.writeText "hyprland-greeter.lua" ''
    ${lib.concatMapStringsSep "\n" (
      o: ''hl.monitor({ output = "${monitorDesc o}", disabled = true })''
    ) cfg.disableOutputs}

    hl.monitor({ output = "${monitorDesc cfg.output}", mode = "preferred", position = "0x0", scale = 1 })

    hl.config({
      misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
      },
      ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
      },
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd("sh -c '${lib.getExe config.services.displayManager.regreet.package}; ${config.programs.hyprland.package}/bin/hyprctl dispatch \"hl.dsp.exit()\"'")
    end)
  '';
in
{
  options.desktop.regreet = {
    enable = lib.mkEnableOption "ReGreet display greeter";

    output = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "ASUSTek COMPUTER INC PG34WCDN W4LMAS016832";
      description = ''
        Run the greeter inside a dedicated Hyprland instance pinned to this monitor
        (matched by its make, model and serial) instead of cage. Leave null to use the default cage
        compositor, which spans all monitors and centres the greeter on the seam.
      '';
    };

    disableOutputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "GSV GSV HDMI2.1   0x00000001" ];
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

    services.displayManager.regreet = {
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

    # When an output is chosen, drive the greeter with Hyprland (pinned to that
    # output) rather than the default cage compositor.
    services.greetd.settings.default_session.command = lib.mkIf (cfg.output != null) (
      "${pkgs.dbus}/bin/dbus-run-session ${config.programs.hyprland.package}/bin/start-hyprland --path ${config.programs.hyprland.package}/bin/Hyprland -- -c ${greeterConfig}"
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
