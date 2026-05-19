{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.zellij;
in
{
  options.${namespace}.zellij = {
    enable = lib.mkEnableOption "Zellij terminal multiplexer";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
    };
  };
}
