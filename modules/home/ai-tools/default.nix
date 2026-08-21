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
  pi = llm-agents.pi;
  antigravity-cli = llm-agents.antigravity-cli;
  dsh = llm-agents.dsh;
  omp = llm-agents.omp;
in
{
  options.${namespace}.ai-tools = {
    enable = lib.mkEnableOption "AI dev tools (master switch)";
    droid.enable = lib.mkEnableOption "Droid agent from llm-agents.nix";
    pi.enable = lib.mkEnableOption "Pi agent from llm-agents.nix";
    antigravity-cli.enable = lib.mkEnableOption "Antigravity CLI from llm-agents.nix";
    dsh.enable = lib.mkEnableOption "DeepSeek harness (dsh) from llm-agents.nix";
    omp.enable = lib.mkEnableOption "OMP agent from llm-agents.nix";
    claude-code.enable = lib.mkEnableOption "Claude Code (Anthropic)";
    daemon = {
      enable = lib.mkEnableOption "Droid daemon (background service)";
      remoteAccess = lib.mkEnableOption "Allow remote access to droid daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optional cfg.droid.enable droid
      ++ lib.optional cfg.pi.enable pi
      ++ lib.optional cfg.antigravity-cli.enable antigravity-cli
      ++ lib.optional cfg.dsh.enable dsh
      ++ lib.optional cfg.omp.enable omp
      ++ lib.optional cfg.claude-code.enable pkgs.claude-code;

    systemd.user.services.droid = lib.mkIf (cfg.daemon.enable && cfg.droid.enable) {
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
