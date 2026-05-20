# Home configuration for kbb on Desktop
{ config, ... }:
{
  # Enable modules
  kbb = {
    fish.enable = true;
    starship.enable = true;
    zellij.enable = true;
    ghostty.enable = true;
    fastfetch.enable = true;
    vscode.enable = true;
    git.enable = true;
    browsers.enable = true;
    ai-tools.enable = true;
    telegram.enable = true;
    _1password.enable = true;
    mpv.enable = true;
    obs.enable = true;
    lazydocker.enable = true;
    nodejs.enable = true;
    cli-tools.enable = true;
    onlyoffice.enable = true;
    rustdesk.enable = true;
    discord.enable = true;
  };

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      # Make Chromium-family browsers (Edge, Chrome) run natively on Wayland
      # instead of XWayland — fixes flicker on KDE Plasma 6 + NVIDIA.
      NIXOS_OZONE_WL = "1";
    };

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    file."external".source = config.lib.file.mkOutOfStoreSymlink "/mnt/data";

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
