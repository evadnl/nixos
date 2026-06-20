{ pkgs, ... }:

{
  home.stateVersion = "26.05";
  home.packages = [ pkgs.home-manager ];

  # Opt into the upcoming catppuccin semantics: `enable` becomes a global
  # toggle and `autoEnable` controls per-port auto-enrollment. We enable
  # integrations explicitly per app, so keep auto-enrollment off.
  catppuccin = {
    enable = true;
    autoEnable = false;
  };
}
