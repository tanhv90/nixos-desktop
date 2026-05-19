{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.ssh;
in
{
  options.${namespace}.ssh = {
    enable = lib.mkEnableOption "OpenSSH server";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
