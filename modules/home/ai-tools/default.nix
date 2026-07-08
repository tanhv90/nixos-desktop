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
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  droid = llm-agents.droid;
  antigravity-cli = llm-agents.antigravity-cli;
in
{
  options.${namespace}.ai-tools = {
    enable = lib.mkEnableOption "AI dev tools (Claude Code, Droid, Antigravity CLI)";
    daemon = {
      enable = lib.mkEnableOption "Droid daemon (background service)";
      remoteAccess = lib.mkEnableOption "Allow remote access to droid daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.claude-code
      droid
      antigravity-cli
    ];

    systemd.user.services.droid = lib.mkIf cfg.daemon.enable {
      Unit = {
        Description = "Droid daemon for AI agent control";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = "${droid}/bin/droid daemon${lib.optionalString cfg.daemon.remoteAccess " --remote-access"}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
