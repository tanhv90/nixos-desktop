# Desktop - Stationary PC (i7-13700F, RTX 3060, 32GB DDR4)
{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
    inputs.mandara.nixosModules.default
    ./hardware.nix
    ./disk.nix
  ];

  # Enable modules
  kbb = {
    fish.enable = true; # system-level, required for fish as login shell
    docker.enable = true;
    fcitx5 = {
      enable = true;
      users = [ "kbb" ];
    };
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale/auth_key".path;
      exitNode = true;
      ssh = true;
    };
    cloudflared = {
      enable = true;
      tokenFile = config.sops.secrets."cloudflared/tunnel_token".path;
    };
    cups.enable = true;
    ssh.enable = true;
    sunshine.enable = true;
    steam.enable = true;
    fonts.enable = true;
  };

  # Timezone
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  # Networking
  networking = {
    hostName = "Desktop";
    networkmanager.enable = true;
  };

  # Umbriel (wlroots compositor) is the session this machine logs into.
  # COSMIC stays installed on purpose: its module supplies the portals and
  # session services, and it remains selectable in the greeter as a fallback.
  # Nothing from it runs unless you pick the COSMIC session at login. To drop
  # it completely, set services.desktopManager.cosmic.enable = false and
  # remove "cosmic" from the session list below.
  programs.umbriel.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.defaultSession = "umbriel";

  # Login screen: Mandara Login (GPUI, greetd + cage) instead of a TUI.
  # The module wires greetd itself, registers the `mandara-lock` PAM service,
  # and defaults the fonts/services/portal pieces to what Mandara's Studio
  # expects (all mkDefault, so the COSMIC desktop module keeps its choices).
  # The package is pinned to the flake's cached build: the module default
  # would compile the shell with our nixpkgs.
  programs.mandara = {
    enable = true;
    package = inputs.mandara.packages.${pkgs.stdenv.hostPlatform.system}.mandara;
    greeter.enable = true;
  };

  # Portals: the cosmic desktop module configures xdg.portal with
  # xdg-desktop-portal-cosmic + -gtk; programs.umbriel adds
  # xdg-desktop-portal-umbriel for screen sharing under Umbriel.

  # Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # NVIDIA proprietary drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      # No `package` pin — uses nixpkgs default (newest production driver),
      # same as the /mnt/data/nixos-config checkout. Verify with
      # `nvidia-smi` and `docker run --gpus all <image> nvidia-smi` after rebuild.
    };
  };

  # NTFS data partition (second NVMe)
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/4F39D88A0D52E8C5";
    fsType = "ntfs3";
    options = [
      "defaults"
      "nofail"
      "uid=1000"
      "gid=100"
    ];
  };

  # SOPS secrets
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops/age/keys.txt";
    secrets."user/kbb_hashed_password".neededForUsers = true;
    secrets."cloudflared/tunnel_token" = { };
    secrets."tailscale/auth_key" = { };
    secrets."opencode/password" = {
      owner = "kbb";
    };
    # Dedicated GitHub SSH key for AI agents / headless git (not 1Password)
    secrets."github/ssh_private_key" = {
      owner = "kbb";
    };
  };

  # User account
  users.mutableUsers = false;
  users.users.kbb = {
    isNormalUser = true;
    hashedPasswordFile = "/run/secrets-for-users/user/kbb_hashed_password";
    extraGroups = [ "wheel" "networkmanager" "docker" "uinput" "input" ];
    shell = pkgs.fish;
    linger = true;
  };

  programs.zsh.enable = true;

  # Pin GitHub's host key so headless agents never hit an interactive prompt
  programs.ssh.knownHosts."github.com" = {
    hostNames = [ "github.com" ];
    publicKey = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  # Nix LD — provide standard FHS lib paths for pre-built binaries (uv, etc.).
  # The GTK/Electron set below lets apps installed outside Nix — notably
  # Factory Desktop, installed by its own .sh installer into
  # ~/.local/share/factory-desktop — find their runtime libraries.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib

    # Electron (Chromium) runtime
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libdrm
    libgbm
    libGL
    libnotify
    libpulseaudio
    libsecret
    libxkbcommon
    nspr
    nss
    pango
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    libxcb
    libxshmfence
  ];

  # Nix settings
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "root" "kbb" ];
      auto-optimise-store = true;
      extra-substituters = [
        "https://cache.numtide.com"
        "https://mandara.cachix.org"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "mandara.cachix.org-1:oOp26vScHzVwCDKAGScpvgPFE8r06UQpDyCdA5u1gh8="
      ];
    };
  };

  # System packages (essentials only — apps go in home-manager)
  environment.systemPackages = with pkgs; [
    git
    vim
    sops
    ffmpeg
    firefox
    ntfs3g
    pciutils
    usbutils
    lm_sensors
    smartmontools
    wl-clipboard-rs
  ];

  system.stateVersion = "24.11";
}
