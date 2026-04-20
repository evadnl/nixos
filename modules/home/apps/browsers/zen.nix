{ pkgs, ... }:

{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      TranslateEnabled = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
    profiles.default = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        onepassword-password-manager
        return-youtube-dislikes
      ];
      settings = {
        "browser.startup.homepage" = "https://home.evad.nl";
        "browser.sessionstore.resume_from_crash" = true;
        "browser.startup.page" = 3;
        "ui.systemUsesDarkTheme" = 1;
        "browser.in-content.dark-mode.enabled" = true;
        "media.hardwaremediakeys.enabled" = false;
        "zen.tabs.show-newtab-vertical" = false;
        "zen.urlbar.behavior" = "float";
        "zen.view.compact.enable-at-startup" = false;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.toolbar-flash-popup" = false;
        "zen.view.show-newtab-button-top" = false;
        "zen.view.window.scheme" = 2;
        "zen.welcome-screen.seen" = true;
        "zen.workspaces.continue-where-left-off" = true;

        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;

        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.partition.network_state.ocsp_cache" = true;
        "privacy.fingerprintingProtection" = true;

        "network.cookie.cookieBehavior" = 5;
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        "network.trr.mode" = 2;

        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.send_pings" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "beacon.enabled" = false;
        "dom.battery.enabled" = false;
      };
    };
  };
}
