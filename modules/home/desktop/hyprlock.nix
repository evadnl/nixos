{ ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };

      background = [
        {
          path = "$HOME/.cache/current-wallpaper";
          blur_passes = 1;
          blur_size = 4;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -20";
          halign = "center";
          valign = "center";
          placeholder_text = "Password...";
          fade_on_empty = true;
          outline_thickness = 3;
          outer_color = "rgba(180, 190, 254, 0.8)";
          inner_color = "rgba(24, 24, 37, 0.8)";
          font_color = "rgb(205, 214, 244)";
          check_color = "rgba(166, 227, 161, 0.8)";
          fail_color = "rgba(243, 139, 168, 0.8)";
          rounding = 12;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font Propo";
          color = "rgba(205, 214, 244, 0.9)";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:3600000] date +\"%A, %B %d\"";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font Propo";
          color = "rgba(180, 190, 254, 0.8)";
          position = "0, 70";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
