# Home configuration for kbb on Desktop
{ config, pkgs, ... }:
{
  # Enable modules
  kbb = {
    fish.enable = false; # temporarily disabled in favor of zsh
    zsh.enable = true;
    starship.enable = true;
    zellij.enable = true;
    ghostty.enable = true;
    fastfetch.enable = true;
    vscode.enable = true;
    git.enable = true;
    browsers.enable = true;
    ai-tools = {
      enable = true;
      daemon = {
        enable = true;
        remoteAccess = true;
      };
    };
    telegram.enable = true;
    _1password.enable = true;
    mpv.enable = true;
    obs.enable = true;
    lazydocker.enable = true;
    nodejs.enable = true;
    python.enable = true;
    cli-tools.enable = true;
    direnv.enable = true;
    onlyoffice.enable = true;
    calibre.enable = true;
    rustdesk.enable = true;
    discord.enable = true;
    appimage.enable = true;
    neovim.enable = true;
    proton-vpn.enable = true;
    opencode = {
      enable = true;
      port = 12121;
      hostname = "0.0.0.0";
      cors = "*";
      auth.passwordFile = "/run/secrets/opencode/password";
    };
  };

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      # Make Chromium-family browsers (Edge, Chrome) run natively on Wayland
      # instead of XWayland — fixes flicker on KDE Plasma 6 + NVIDIA.
      NIXOS_OZONE_WL = "1";
      # Provide libstdc++ for pre-built Python wheels (numpy/chromadb via uv)
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];

    file."external".source = config.lib.file.mkOutOfStoreSymlink "/mnt/data";

    stateVersion = "24.11";

    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;
}
