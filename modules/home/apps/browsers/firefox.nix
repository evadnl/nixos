{ ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.startup.homepage" = "https://home.evad.nl";
        "ui.systemUsesDarkTheme" = 1;
        "browser.in-content.dark-mode.enabled" = true;
      };
    };
  };
}
