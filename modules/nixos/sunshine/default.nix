{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.sunshine;
in
{
  options.${namespace}.sunshine = {
    enable = lib.mkEnableOption "Sunshine GameStream host for Moonlight";
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # required for Wayland KMS capture
      openFirewall = true;
    };
  };
}
