{
  lib,
  config,
  inputs,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.ai-tools;
  droid = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.droid;
in
{
  options.${namespace}.ai-tools = {
    enable = lib.mkEnableOption "AI dev tools (Claude Code, Droid)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.claude-code
      droid
    ];
  };
}
