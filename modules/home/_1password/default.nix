{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}._1password;
in
{
  options.${namespace}._1password = {
    enable = lib.mkEnableOption "1Password password manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs._1password-gui.overrideAttrs (_: {
        src = pkgs.fetchurl {
          url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-8.12.21.x64.tar.gz";
          hash = "sha256-JwiMi2iozP6jWSIUtgXla86aSAhuUob7snqtUbeXPpI=";
        };
      }))
    ];
  };
}
