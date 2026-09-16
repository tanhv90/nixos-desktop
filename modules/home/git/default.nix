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

    # GitHub uses the sops-deployed dedicated key (works for AI agents and
    # remote SSH sessions where the 1Password agent isn't available).
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        # Replicates home-manager's former default Host * block
        "*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          ForwardAgent = false;
          HashKnownHosts = false;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 0;
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
        "github.com" = {
          user = "git";
          identityFile = "/run/secrets/github/ssh_private_key";
          identitiesOnly = true;
        };
      };
    };
  };
}
