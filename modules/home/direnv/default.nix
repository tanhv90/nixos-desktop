{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.direnv;
in
{
  options.${namespace}.direnv = {
    enable = lib.mkEnableOption "direnv with nix-direnv integration";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      config = {
        hide_env_diff = true;
      };
    };
  };
}
