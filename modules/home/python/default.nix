{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.python;
in
{
  options.${namespace}.python = {
    enable = lib.mkEnableOption "Python 3.12 + uv";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python312
      uv
    ];
  };
}
