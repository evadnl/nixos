{ pkgs, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude/settings.json".text = builtins.toJSON {
    env = {
      ENABLE_CLAUDEAI_MCP_SERVERS = "false";
    };
  };
}
