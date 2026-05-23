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
    ./hardware.nix
    ./disk.nix
  ];

  # Enable modules
  kbb = {
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
    ssh.enable = true;
    fonts.enable = true;
    rustdesk.enable = true;
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

  # KDE Plasma 6 + Wayland
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # XDG desktop portal — required for RustDesk PipeWire screen capture on Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = "kde";
  };

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
      # Frozen 580 branch. Has explicit-sync (≥555) so KDE Plasma 6 Wayland
      # works without Qt-Wayland xdg_surface crashes (Telegram, etc.). Pinned
      # to legacy_580 rather than `stable` so `nix flake update` only bumps
      # within the 580.x line — no surprise jumps to 600+. CUDA 12 Docker
      # images run via nvidia-container-toolkit forward-compat — verify with
      # `docker run --gpus all <image> nvidia-smi` after rebuild.
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
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
  };

  # User account
  users.mutableUsers = false;
  users.users.kbb = {
    isNormalUser = true;
    hashedPasswordFile = "/run/secrets-for-users/user/kbb_hashed_password";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
    linger = true;
  };

  programs.fish.enable = true;

  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "root" "kbb" ];
    auto-optimise-store = true;
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
  ];

  system.stateVersion = "24.11";
}
