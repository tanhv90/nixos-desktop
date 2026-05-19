{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.mpv;
in
{
  options.${namespace}.mpv = {
    enable = lib.mkEnableOption "mpv media player";
  };

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}
