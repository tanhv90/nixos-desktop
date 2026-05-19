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
    enable = lib.mkEnableOption "RustDesk remote desktop";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rustdesk ];
  };
}
