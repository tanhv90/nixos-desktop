{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}._1password;
in
{
  options.${namespace}._1password = {
    enable = lib.mkEnableOption "1Password password manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs._1password-gui ];
  };
}
