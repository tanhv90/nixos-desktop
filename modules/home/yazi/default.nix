{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.yazi;

  # yazi-rs/plugins ships many Lua plugins in a single repo, so one pinned
  # fetch covers all of them. Individual plugins are selected by store subpath.
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "58c4f4e2f4835cc9bf6751f39e3f7c574fc7f55a";
    hash = "sha256-kwf9+KXOL5JXGDoEGdtwq+JujP8GVoOwDgz76FBM3xk=";
  };
in
{
  options.${namespace}.yazi = {
    enable = lib.mkEnableOption "Yazi terminal file manager (with RAR extraction support)";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";

      # Swap the bundled 7-Zip for the RAR-enabled build so yazi can extract
      # .rar archives.
      package = pkgs.yazi.override {
        _7zz = pkgs._7zz-rar;
      };

      settings = {
        mgr = {
          show_hidden = true;
        };
        preview = {
          # Yazi renders at min(terminal pixel size, these caps). A high cap
          # keeps previews sharp on HiDPI displays; the terminal size is the
          # real limit.
          max_width = 4096;
          max_height = 4096;
          # Defaults ("triangle", 75) render blurry previews; lanczos3 with the
          # maximum allowed quality (yazi validates 50..=90) is sharper.
          image_filter = "catmull-rom";
          image_quality = 90;
        };
      };

      plugins = {
        chmod = "${yazi-plugins}/chmod.yazi";
        full-border = "${yazi-plugins}/full-border.yazi";
        toggle-pane = "${yazi-plugins}/toggle-pane.yazi";
        starship = pkgs.fetchFromGitHub {
          owner = "Rolv-Apneseth";
          repo = "starship.yazi";
          rev = "ea92cf49380466f07231c952b409831e6afd2156";
          hash = "sha256-Jvoc/7YaOOppu8K2lJaVgiuBIyanRHHjEA6ZvnrFtiQ=";
        };
      };

      initLua = ''
        require("full-border"):setup()
        require("starship"):setup()
      '';

      keymap.mgr.prepend_keymap = [
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
  };
}
