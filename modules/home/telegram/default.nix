{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.telegram;
in
{
  options.${namespace}.telegram = {
    enable = lib.mkEnableOption "Telegram Desktop";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.telegram-desktop ];
  };
}
