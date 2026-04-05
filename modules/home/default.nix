{ config, hostHomeModule, catppuccinHomeModule, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    sharedModules = [ catppuccinHomeModule ];
    users.${config.user.name}.imports = [ hostHomeModule ];
  };
}
