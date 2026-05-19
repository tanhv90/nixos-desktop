{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.fastfetch;
in
{
  options.${namespace}.fastfetch = {
    enable = lib.mkEnableOption "Fastfetch system info tool";
  };

  config = lib.mkIf cfg.enable {
    programs.fastfetch.enable = true;
  };
}
