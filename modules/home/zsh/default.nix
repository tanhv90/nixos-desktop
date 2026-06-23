{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.zsh;
in
{
  options.${namespace}.zsh = {
    enable = lib.mkEnableOption "Zsh shell";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
        strategy = [ "history" "completion" ];
      };
      syntaxHighlighting.enable = true;

      history = {
        size = 100000;
        save = 100000;
        path = "$HOME/.zsh_history";
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        extended = true;
      };

      shellAliases = {
        c = "clear";
      };

      initContent = ''
        setopt autocd
        setopt extendedglob
        setopt nomatch
        setopt notify
        unsetopt beep

        bindkey '^[[C' autosuggest-accept
        bindkey '^[[1;5C' forward-word

        # Generate .envrc for Nix projects and allow direnv
        mkflake() {
          echo "use flake" > .envrc
          direnv allow
        }

        mknix() {
          echo "use nix" > .envrc
          direnv allow
        }
      '';
    };
  };
}
