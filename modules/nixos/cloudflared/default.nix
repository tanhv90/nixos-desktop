{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.cloudflared;
in
{
  options.${namespace}.cloudflared = {
    enable = lib.mkEnableOption "Cloudflare tunnel";
    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing the tunnel connector token.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cloudflared ];

    systemd.services.cloudflared = {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared --no-autoupdate tunnel run --token-file %d/token";
        LoadCredential = "token:${cfg.tokenFile}";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
      };
    };
  };
}
