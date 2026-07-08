{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.lazydocker;
in
{
  options.${namespace}.lazydocker = {
    enable = lib.mkEnableOption "lazydocker TUI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lazydocker ];

    programs.fish.shellAliases = {
      lzdk = "lazydocker";
    };

    programs.zsh.shellAliases = {
      lzdk = "lazydocker";
    };
  };
}
