{ config, hostHomeModule, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.${config.user.name}.imports = [ hostHomeModule ];
  };
}
