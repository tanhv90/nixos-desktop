{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.tailscale;
in
{
  options.${namespace}.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing a Tailscale reusable auth key for unattended login.";
    };
    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Subnets to advertise to the tailnet (e.g. [ \"192.168.1.0/24\" ]).";
    };
    exitNode = lib.mkEnableOption "advertise this machine as a tailnet exit node";
    ssh = lib.mkEnableOption "Tailscale SSH (identity-based SSH via tailnet)";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures =
        if cfg.exitNode || cfg.advertiseRoutes != [ ] then "both" else "client";
      authKeyFile = cfg.authKeyFile;
      extraUpFlags =
        lib.optional cfg.ssh "--ssh"
        ++ lib.optional cfg.exitNode "--advertise-exit-node"
        ++ lib.optional (cfg.advertiseRoutes != [ ])
          "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}";
    };
  };
}
