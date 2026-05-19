{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.nodejs;
in
{
  options.${namespace}.nodejs = {
    enable = lib.mkEnableOption "Node.js 25 toolchain";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_25
      bun
    ];
  };
}
