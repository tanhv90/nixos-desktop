{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.opencode;

  baseArgs = "--port ${toString cfg.port} --hostname ${cfg.hostname} --cors ${cfg.cors}";

  execCmd =
    if cfg.auth.passwordFile != null then
      let
        wrapper = pkgs.writeShellScript "opencode-serve" ''
          export OPENCODE_SERVER_PASSWORD="$(cat ${cfg.auth.passwordFile})"
          export OPENCODE_SERVER_USERNAME="${cfg.auth.username}"
          exec ${pkgs.opencode}/bin/opencode serve ${baseArgs}
        '';
      in
      "${wrapper}"
    else
      "${pkgs.opencode}/bin/opencode serve ${baseArgs}";
in
{
  options.${namespace}.opencode = {
    enable = lib.mkEnableOption "OpenCode HTTP server daemon";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for opencode serve";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Hostname to bind";
    };
    cors = lib.mkOption {
      type = lib.types.str;
      default = "*";
      description = "CORS origin";
    };
    auth.passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing the HTTP basic auth password";
    };
    auth.username = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = "Username for HTTP basic auth";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.opencode ];

    systemd.user.services.opencode = {
      Unit = {
        Description = "OpenCode HTTP Server";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = execCmd;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
