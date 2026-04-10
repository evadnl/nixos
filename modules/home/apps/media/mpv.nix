{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override {
      scripts = with pkgs.mpvScripts; [
        mpris # MPRIS support (media keys, waybar, etc.)
        thumbfast # fast seekbar thumbnails
        uosc # modern minimal UI
      ];
    };

    config = {
      # Video
      profile = "high-quality";
      vo = "gpu-next";
      hwdec = "auto-safe";
      gpu-api = "vulkan";

      # Interpolation / smoothness
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";

      # Audio
      volume = 80;
      volume-max = 150;
      audio-channels = "auto";

      # Subtitles
      sub-auto = "fuzzy";
      slang = "en,eng";
      alang = "en,eng,ja,jpn";
      sub-font = "Noto Sans";
      sub-font-size = 40;
      sub-border-size = 2.5;

      # Behavior
      save-position-on-quit = true;
      keep-open = true;
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/mpv";

      # OSC disabled because uosc replaces it
      osc = false;
      osd-bar = false;
      border = false;
    };

    bindings = {
      MBTN_LEFT = "cycle pause";
      MBTN_RIGHT = "script-binding uosc/menu";
      WHEEL_UP = "add volume 5";
      WHEEL_DOWN = "add volume -5";
    };
  };
}
