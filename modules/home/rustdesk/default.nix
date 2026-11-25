{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.rustdesk;
  package = pkgs.rustdesk-flutter.overrideAttrs (prev: {
    # rustdesk 1.5.0 gained a libsodium-sys dependency; the pinned
    # nixpkgs still lacks it in buildInputs. Ported from nixpkgs master.
    buildInputs = prev.buildInputs ++ [ pkgs.libsodium ];
  });
in
{
  options.${namespace}.rustdesk = {
    enable = lib.mkEnableOption "RustDesk remote desktop";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];

    # Background server so incoming connections work without opening the GUI.
    systemd.user.services.rustdesk = {
      Unit = {
        Description = "RustDesk remote desktop server";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${package}/bin/rustdesk --server";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
