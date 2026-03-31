{ config, ... }:

{
  home-manager.users.${config.user.name} = {
    programs.vscode.enable = true;
  };
}
