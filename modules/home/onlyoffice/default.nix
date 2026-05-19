{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.onlyoffice;
in
{
  options.${namespace}.onlyoffice = {
    enable = lib.mkEnableOption "ONLYOFFICE Desktop Editors";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
