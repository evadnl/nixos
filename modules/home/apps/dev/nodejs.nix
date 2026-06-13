{ pkgs, ... }:

{
  # Provides node, npm and npx
  home.packages = [ pkgs.nodejs ];
}
