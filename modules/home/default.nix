{ config, hostHomeModule, catppuccinHomeModule, noctaliaHomeModule, zenBrowserModule, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    sharedModules = [ catppuccinHomeModule noctaliaHomeModule zenBrowserModule ];
    users.${config.user.name}.imports = [ hostHomeModule ];
  };
}
