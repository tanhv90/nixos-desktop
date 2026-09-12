{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.steam;
in
{
  options.${namespace}.steam = {
    enable = lib.mkEnableOption "Steam gaming platform";
  };

  config = lib.mkIf cfg.enable {
    # Implies hardware.steam-hardware.enable (controller/Index udev rules)
    # and requires nixpkgs.config.allowUnfree (set in flake.nix).
    programs.steam.enable = true;
  };
}
