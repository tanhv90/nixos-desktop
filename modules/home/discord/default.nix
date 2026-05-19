{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.discord;
in
{
  options.${namespace}.discord = {
    enable = lib.mkEnableOption "Discord";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.discord ];
  };
}
