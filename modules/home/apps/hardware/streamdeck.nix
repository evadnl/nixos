{ pkgs, ... }:

{
  home.packages = [ pkgs.streamcontroller ];

  # Run as a restart-on-failure user service: a bare spawn-at-startup races the
  # USB/udev stack at login and cores out without ever coming back.
  systemd.user.services.streamcontroller = {
    Unit = {
      Description = "StreamController (Elgato Stream Deck)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.streamcontroller}/bin/streamcontroller -b";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
