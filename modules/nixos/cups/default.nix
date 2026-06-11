{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.cups;
in
{
  options.${namespace}.cups = {
    enable = lib.mkEnableOption "CUPS printing with driverless IPP support";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
