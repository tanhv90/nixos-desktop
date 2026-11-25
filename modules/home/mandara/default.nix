{
  lib,
  config,
  inputs,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.mandara;
  # The package Mandara's own lock builds, so mandara.cachix.org substitutes it
  # instead of compiling the shell with our nixpkgs.
  mandaraPackage = inputs.mandara.packages.${pkgs.stdenv.hostPlatform.system}.mandara;
in
{
  options.${namespace}.mandara = {
    enable = lib.mkEnableOption "Mandara Wayland shell (bar, dock, notifications)";

    settings = lib.mkOption {
      type = (pkgs.formats.toml { }).type;
      default = { };
      example = lib.literalExpression ''
        {
          bar.height = 30;
          typography.ui_font = "Inter";
        }
      '';
      description = ''
        Written to ~/.config/mandara/config.toml. Empty (the default) leaves
        the file to Mandara Studio; once anything is set here, the file is
        owned by Home Manager and Studio edits stop being saved.
      '';
    };

    systemd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start Mandara as a systemd user service with the graphical session.
        COSMIC brings up graphical-session.target and exports WAYLAND_DISPLAY,
        so this replaces adding it to COSMIC Settings → Startup applications.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mandara = {
      enable = true;
      package = mandaraPackage;
      inherit (cfg) settings;
      systemd.enable = cfg.systemd;
    };
  };
}
