{ config, hostHomeModule, catppuccinHomeModule, noctaliaHomeModule, plasmaHomeModule, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    sharedModules = [ catppuccinHomeModule noctaliaHomeModule plasmaHomeModule ];
    users.${config.user.name}.imports = [ hostHomeModule ];
  };
}
