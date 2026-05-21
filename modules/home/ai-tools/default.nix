{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.ai-tools;
in
{
  options.${namespace}.ai-tools = {
    enable = lib.mkEnableOption "Claude Code CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
