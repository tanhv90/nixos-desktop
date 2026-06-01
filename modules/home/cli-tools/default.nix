{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.cli-tools;
in
{
  options.${namespace}.cli-tools = {
    enable = lib.mkEnableOption "default must-have CLI tools (fd, ripgrep, gh, ...)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      ripgrep
      gh
      jq
      bat
      fzf
      eza
      delta
      btop
      zoxide
    ];

    programs.bat = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
    };

    programs.zoxide = {
      enable = true;
    };

    programs.eza = {
      enable = true;
      icons = "auto";
      git = true;
    };

    programs.git = {
      enable = true;
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.fish.shellAliases = {
      cat = "bat";
      manp = "batman";
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
    };
  };
}
