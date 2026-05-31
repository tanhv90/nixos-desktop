{
  lib,
  config,
  pkgs,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.fcitx5;
in
{
  options.${namespace}.fcitx5 = {
    enable = lib.mkEnableOption "fcitx5 input method with Lotus";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users to enable fcitx5-lotus service for.";
    };
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-lua
        qt6Packages.fcitx5-configtool
      ];
    };

    services.fcitx5-lotus = {
      enable = true;
      users = cfg.users;
    };
  };
}
