{
  lib,
  config,
  inputs,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.browsers;
in
{
  options.${namespace}.browsers = {
    enable = lib.mkEnableOption "Web browsers (Zen)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.microsoft-edge
      pkgs.google-chrome
      pkgs.vivaldi
      pkgs.vivaldi-ffmpeg-codecs
    ];
  };
}
