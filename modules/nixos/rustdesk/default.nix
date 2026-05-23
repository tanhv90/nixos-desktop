{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.rustdesk;
in
{
  options.${namespace}.rustdesk = {
    enable = lib.mkEnableOption "RustDesk remote desktop service for unattended access";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rustdesk = {
      description = "RustDesk Remote Desktop Service";
      requires = [ "network.target" ];
      after = [
        "network.target"
        "systemd-user-sessions.service"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.rustdesk-flutter}/bin/rustdesk --service";
        ExecStop = "${pkgs.procps}/bin/pkill -f 'rustdesk --'";
        PIDFile = "/run/rustdesk.pid";
        KillMode = "mixed";
        TimeoutStopSec = 30;
        User = "root";
        LimitNOFILE = 100000;
        Environment = [
          "PULSE_LATENCY_MSEC=60"
          "PIPEWIRE_LATENCY=1024/48000"
        ];
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
