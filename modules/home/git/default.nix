{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.git;
in
{
  options.${namespace}.git = {
    enable = lib.mkEnableOption "Git version control";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings.user.name = "tanhv90";
      settings.user.email = "tanhv90@gmail.com";
    };
  };
}
