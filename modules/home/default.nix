{ config, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${config.user.name} = {
      home.stateVersion = "26.05";
    };
  };
}
