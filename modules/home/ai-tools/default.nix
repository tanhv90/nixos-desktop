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
    enable = lib.mkEnableOption "AI coding tools (claude-code, opencode)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
      opencode
    ];
  };
}
