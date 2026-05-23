{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.cli-tools;
in
{
  options.${namespace}.cli-tools = {
    enable = lib.mkEnableOption "default must-have CLI tools (fd, ripgrep, gh)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      ripgrep
      gh
    ];
  };
}
