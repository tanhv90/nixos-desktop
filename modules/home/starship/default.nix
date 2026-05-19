{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.starship;
in
{
  options.${namespace}.starship = {
    enable = lib.mkEnableOption "Starship prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
