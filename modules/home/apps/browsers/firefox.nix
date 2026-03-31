{ config, ... }:

{
  home-manager.users.${config.user.name} = {
    programs.firefox.enable = true;
  };
}
