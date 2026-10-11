{ config, hostHomeModule, catppuccinHomeModule, noctaliaHomeModule, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    sharedModules = [ catppuccinHomeModule noctaliaHomeModule ];
    users.${config.user.name}.imports = [ hostHomeModule ];
  };
}
