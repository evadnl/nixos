{ config, ... }:

{
  xdg.configFile."rofi/powermenu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      theme_file="${config.xdg.configHome}/rofi/powermenu.rasi"

      # Options (Nerd Font icons via bash unicode escapes)
      lock=$'\uf023'        # nf-fa-lock
      logout=$'\uf2f5'      # nf-fa-sign_out_alt
      sleep=$'\uf186'       # nf-fa-moon_o
      reboot=$'\uf021'      # nf-fa-refresh
      shutdown=$'\uf011'    # nf-fa-power_off
      uefi=$'\U000f035b'    # nf-md-chip

      # order: lock(0) logout(1) sleep(2) reboot(3) shutdown(4) uefi(5)
      chosen_idx=$(echo -e "$lock\n$logout\n$sleep\n$reboot\n$shutdown\n$uefi" \
        | rofi -dmenu -format i -theme "$theme_file")

      case "$chosen_idx" in
        0) swaylock-random ;;
        1) niri msg action quit ;;
        2) systemctl hybrid-sleep ;;
        3) systemctl reboot ;;
        4) systemctl poweroff ;;
        5) systemctl reboot --firmware-setup ;;
      esac
    '';
  };

  xdg.configFile."rofi/powermenu.rasi".text = ''
    * {
        font:              "JetBrainsMono Nerd Font Propo 14";
        background:        #1e1e2ee6;
        background-alt:    #313244e6;
        foreground:        #cdd6f4ff;
        selected:          #89b4faff;
        active:            #a6e3a1ff;
        urgent:            #f38ba8ff;
    }

    window {
        transparency:      "real";
        location:          center;
        anchor:            center;
        fullscreen:        false;
        width:             750px;
        border:            0px solid;
        border-radius:     0px;
        border-color:      @selected;
        background-color:  @background;
        cursor:            "default";
    }

    mainbox {
        spacing:           10px;
        padding:           20px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  transparent;
        children:          [ "listview" ];
    }

    listview {
        columns:           6;
        lines:             1;
        cycle:             true;
        dynamic:           true;
        scrollbar:         false;
        layout:            vertical;
        fixed-height:      true;
        fixed-columns:     true;
        spacing:           10px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  transparent;
        text-color:        @foreground;
        cursor:            "default";
    }

    element {
        spacing:           0px;
        padding:           10px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  @background-alt;
        text-color:        @foreground;
        cursor:            pointer;
        children:          [ "element-text" ];
    }

    element-text {
        background-color:  transparent;
        text-color:        inherit;
        cursor:            inherit;
        vertical-align:    0.5;
        horizontal-align:  0.5;
    }

    element selected.normal {
        border:            0px 2px 0px 2px;
        border-radius:     0px;
        background-color:  @selected;
        text-color:        @background;
    }

    error-message {
        padding:           10px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  @background;
        text-color:        @foreground;
    }
  '';

  xdg.desktopEntries."power-menu" = {
    name = "Power Menu";
    exec = "${config.xdg.configHome}/rofi/powermenu.sh";
    icon = "system-shutdown";
    categories = [ "System" ];
    comment = "Shutdown, reboot, suspend or hibernate";
  };

  # Write the full self-contained theme — inlines colors and font, no shared/ imports needed
  xdg.configFile."rofi/theme.rasi".text = ''
    * {
        background:        #1e1e2ee6;
        background-alt:    #313244e6;
        foreground:        #cdd6f4ff;
        selected:          #89b4faff;
        active:            #a6e3a1ff;
        urgent:            #f38ba8ff;
    }

    window {
        transparency:      "real";
        location:          center;
        anchor:            center;
        fullscreen:        false;
        width:             700px;
        border:            0px solid;
        border-radius:     0px;
        border-color:      @selected;
        background-color:  @background;
        cursor:            "default";
    }

    mainbox {
        spacing:           10px;
        padding:           20px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  transparent;
        children:          [ "inputbar", "listview" ];
    }

    inputbar {
        spacing:           10px;
        padding:           15px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  @background-alt;
        text-color:        @foreground;
        children:          [ "prompt", "entry" ];
    }

    prompt {
        background-color:  inherit;
        text-color:        inherit;
    }

    entry {
        background-color:  inherit;
        text-color:        inherit;
        cursor:            text;
        placeholder:       "Search...";
        placeholder-color: inherit;
    }

    listview {
        columns:           2;
        lines:             8;
        cycle:             true;
        dynamic:           true;
        scrollbar:         false;
        layout:            vertical;
        fixed-height:      true;
        fixed-columns:     true;
        spacing:           5px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  transparent;
        text-color:        @foreground;
        cursor:            "default";
    }

    element {
        spacing:           10px;
        padding:           5px;
        border:            0px solid;
        border-radius:     0px;
        background-color:  transparent;
        text-color:        @foreground;
        cursor:            pointer;
    }

    element normal.normal {
        background-color:  @background;
        text-color:        @foreground;
    }

    element selected.normal {
        background-color:  @selected;
        text-color:        @background;
    }

    element-icon {
        background-color:  transparent;
        text-color:        inherit;
        size:              32px;
        cursor:            inherit;
    }

    element-text {
        background-color:  transparent;
        text-color:        inherit;
        highlight:         inherit;
        cursor:            inherit;
        vertical-align:    0.5;
        horizontal-align:  0.0;
    }

    error-message {
        padding:           15px;
        border:            2px solid;
        border-radius:     0px;
        border-color:      @selected;
        background-color:  @background;
        text-color:        @foreground;
    }
  '';

  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font Propo 12";
    terminal = "ghostty";
    theme = "${config.xdg.configHome}/rofi/theme.rasi";
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "";
    #   me-accept-entry = "MousePrimary";
    };
  };
}
