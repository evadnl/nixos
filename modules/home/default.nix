{ config, hostHomeModule, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${config.user.name}.imports = [ hostHomeModule ];
  };
}
