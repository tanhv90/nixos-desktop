{
  lib,
  config,
  pkgs,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.opencode;
  # Direct from github:numtide/llm-agents.nix, same as droid/pi/antigravity-cli.
  opencode2 = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;

  baseArgs = "--port ${toString cfg.port} --hostname ${cfg.hostname}";

  # opencode2 dropped opencode 1.x's --cors CLI flag; allowed origins go
  # through the `server.cors` config, injected via OPENCODE_CONFIG_CONTENT
  # (merged on top of any opencode.json). Unlike 1.x there is no "*" wildcard.
  corsFile =
    if cfg.cors != null then
      pkgs.writeText "opencode-server-cors.json" (
        builtins.toJSON { server.cors = lib.splitString "," cfg.cors; }
      )
    else
      null;

  execCmd =
    let
      serveCmd = "${opencode2}/bin/opencode2 serve ${baseArgs}";
    in
    if cfg.auth.passwordFile != null then
      pkgs.writeShellScript "opencode-serve" ''
        ${lib.optionalString (corsFile != null) "export OPENCODE_CONFIG_CONTENT=\"$(cat ${corsFile})\""}
        export OPENCODE_SERVER_PASSWORD="$(cat ${cfg.auth.passwordFile})"
        export OPENCODE_SERVER_USERNAME="${cfg.auth.username}"
        exec ${serveCmd}
      ''
    else if corsFile != null then
      pkgs.writeShellScript "opencode-serve" ''
        export OPENCODE_CONFIG_CONTENT="$(cat ${corsFile})"
        exec ${serveCmd}
      ''
    else
      serveCmd;
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
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Comma-separated origins to allow for CORS (mapped to opencode2's
        `server.cors` config). opencode2 has no "*" wildcard — set explicit
        origins when a web client on another origin needs access.
      '';
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
    home.packages = [ opencode2 ];

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
