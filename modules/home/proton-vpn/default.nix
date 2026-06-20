{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.proton-vpn;
in
{
  options.${namespace}.proton-vpn = {
    enable = lib.mkEnableOption "Proton VPN";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.protonvpn-gui ];
  };
}
