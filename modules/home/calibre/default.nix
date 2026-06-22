{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.calibre;
in
{
  options.${namespace}.calibre = {
    enable = lib.mkEnableOption "Calibre e-book manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.calibre ];
  };
}
