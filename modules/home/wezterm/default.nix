{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.wezterm;
in
{
  options.${namespace}.wezterm = {
    enable = lib.mkEnableOption "WezTerm terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;

      extraConfig = ''
        return {
          font = wezterm.font('JetBrainsMono Nerd Font'),
          font_size = 13.0,
          color_scheme = 'rose-pine-moon',
          window_decorations = 'RESIZE',
          window_background_opacity = 0.8,
          wayland_window_background_blur = true,
          hide_tab_bar_if_only_one_tab = true
        }
      '';
    };
  };
}
