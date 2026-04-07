{ ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.startup.homepage" = "https://home.evad.nl";
        "browser.sessionstore.resume_from_crash" = true;
        "browser.startup.page" = 3;
        "ui.systemUsesDarkTheme" = 1;
        "browser.in-content.dark-mode.enabled" = true;
        "media.hardwaremediakeys.enabled" = false;
      };
    };
  };
}
