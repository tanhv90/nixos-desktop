{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.fish;
in
{
  options.${namespace}.fish = {
    enable = lib.mkEnableOption "Fish shell (system-level, required for fish login shells)";
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
  };
}
