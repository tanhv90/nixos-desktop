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

      # Port of the old Ghostty config (JetBrainsMono Nerd Font, Catppuccin,
      # no title bar). Home Manager already provides
      # `local wezterm = require 'wezterm'`.
      # Note: this WezTerm build no longer has color_scheme_dark/light
      # (system-theme following), so it defaults to the dark Catppuccin Mocha.
      extraConfig = ''
        return {
          font = wezterm.font('JetBrainsMono Nerd Font'),
          font_size = 13.0,
          color_scheme = 'rose-pine-moon',
          window_decorations = 'RESIZE',
          window_background_opacity = 0.95,
          wayland_background_opacity = 0.8,
          hide_tab_bar_if_only_one_tab = true
        }
      '';
    };
  };
}
