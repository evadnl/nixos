{ lib, config, ... }:

let
  cfg = config.hardware.keyboard.hyperTab;
in
{
  options.hardware.keyboard.hyperTab = {
    enable = lib.mkEnableOption "Tab as Hyper (Ctrl+Alt+Shift+Super) when held, Tab when tapped";
  };

  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          main.tab = "overload(hyper, tab)";
          "hyper:C-A-S-M" = { };
        };
      };
    };
  };
}
