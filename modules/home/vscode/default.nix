{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.vscode;
in
{
  options.${namespace}.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
    };
  };
}
