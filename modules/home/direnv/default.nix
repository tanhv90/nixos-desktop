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
      stdlib = ''
        # Use flake's devShell automatically when entering a flake directory.
        use_flake() {
          watch_file flake.nix flake.lock
          eval "$(nix print-dev-env --impure)"
        }
      '';
    };
  };
}
