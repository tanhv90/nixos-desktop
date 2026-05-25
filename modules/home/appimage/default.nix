{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.appimage;
in
{
  options.${namespace}.appimage = {
    enable = lib.mkEnableOption "AppImage support via appimage-run";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.appimage-run
    ];
  };
}
