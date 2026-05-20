{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.ghostty;
in
{
  options.${namespace}.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 13;
        theme = "dark:Catppuccin Mocha,light:Catppuccin Latte";
        window-decoration = false;
      };
    };
  };
}
