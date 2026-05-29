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
    enable = lib.mkEnableOption "Fish shell";
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      shellAliases = {
        c = "clear";
      };
    };
  };
}
