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
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
