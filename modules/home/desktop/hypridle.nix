{ pkgs, ... }:

let
  lockScript = pkgs.writeShellScript "lock-session" ''
    pidof hyprlock || hyprlock &
    # Signal 1Password and other apps that listen for screensaver D-Bus
    ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.ScreenSaver \
      /org/freedesktop/ScreenSaver org.freedesktop.ScreenSaver.SetActive boolean:true
  '';
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${lockScript}";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
          on-resume = "";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
