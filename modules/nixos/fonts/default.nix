{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.fonts;
in
{
  options.${namespace}.fonts = {
    enable = lib.mkEnableOption "system fonts (CJK + Nerd Font + emoji)";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            "JetBrainsMono Nerd Font"
            "Noto Sans Mono CJK SC"
            "Noto Sans Mono CJK JP"
            "Noto Sans Mono CJK KR"
          ];
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK SC"
            "Noto Sans CJK JP"
            "Noto Sans CJK KR"
          ];
          serif = [
            "Noto Serif"
            "Noto Serif CJK SC"
            "Noto Serif CJK JP"
            "Noto Serif CJK KR"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
      };
    };
  };
}
