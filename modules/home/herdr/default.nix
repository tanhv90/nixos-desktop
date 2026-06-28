{
  lib,
  config,
  inputs,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.herdr;
in
{
  options.${namespace}.herdr = {
    enable = lib.mkEnableOption "Herdr terminal workspace manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
