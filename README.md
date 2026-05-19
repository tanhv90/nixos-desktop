# kbb's Desktop NixOS Configuration

Clean NixOS flake using **snowfall-lib** with modular structure, designed for multiple hosts.

## Hardware (Desktop)

| Component | Detail |
|-----------|--------|
| CPU | Intel i7-13700F |
| GPU | NVIDIA RTX 3060 (proprietary drivers) |
| RAM | 32GB DDR4 |
| Motherboard | ASUS TUF B660M |
| NVMe 0 (`nvme0n1`) | NixOS — 512M ESP + 32G swap + btrfs root (`@`, `@home`) |
| NVMe 1 (`nvme1n1`) | NTFS data partition (UUID: `4F39D88A0D52E8C5`) → `/mnt/data` |

> NVMe device names can swap between boots. Config uses UUID for the NTFS partition. Disko uses device path for the NixOS drive (only matters at install time).

## Structure (snowfall-lib)

```
nixos-desktop/
├── flake.nix
├── flake.lock
├── .sops.yaml                               # SOPS age public key
├── .gitignore
│
├── systems/x86_64-linux/
│   └── Desktop/                             # Host: Desktop PC
│       ├── default.nix                      # System config — enables modules
│       ├── hardware.nix                     # Hardware detection
│       └── disk.nix                         # Disko btrfs layout
│
├── homes/x86_64-linux/
│   └── kbb@Desktop/                         # Home config for kbb on Desktop
│       └── default.nix                      # Enables home modules
│
├── modules/
│   ├── nixos/                               # System-level modules
│   │   ├── cloudflared/default.nix          # Cloudflare tunnel
│   │   ├── docker/default.nix               # Docker + NVIDIA GPU
│   │   ├── fcitx5/default.nix               # Input method + Lotus
│   │   ├── ssh/default.nix                  # OpenSSH server
│   │   └── tailscale/default.nix            # Tailscale VPN
│   │
│   └── home/                                # User-level modules
│       ├── _1password/default.nix            # 1Password GUI
│       ├── ai-tools/default.nix             # claude-code, opencode
│       ├── browsers/default.nix             # Zen browser
│       ├── fish/default.nix                 # Fish shell
│       ├── ghostty/default.nix              # Ghostty terminal + catppuccin
│       ├── git/default.nix                  # Git config
│       ├── mpv/default.nix                  # mpv media player
│       ├── obs/default.nix                  # OBS Studio
│       ├── starship/default.nix             # Starship prompt
│       ├── telegram/default.nix             # Telegram Desktop
│       ├── vscode/default.nix               # Visual Studio Code
│       └── zellij/default.nix               # Zellij multiplexer
│
└── secrets/                                 # SOPS-encrypted secrets
```

## Module Usage

Modules are toggled per-host with `kbb.<module>.enable = true`.

**System config** (`systems/.../Desktop/default.nix`):
```nix
kbb = {
  docker.enable = true;
  fcitx5.enable = true;
  tailscale.enable = true;
  cloudflared.enable = true;
  ssh.enable = true;
};
```

**Home config** (`homes/.../kbb@Desktop/default.nix`):
```nix
kbb = {
  fish.enable = true;
  starship.enable = true;
  zellij.enable = true;
  ghostty.enable = true;
  vscode.enable = true;
  git.enable = true;
  browsers.enable = true;
  ai-tools.enable = true;
  telegram.enable = true;
  _1password.enable = true;
  mpv.enable = true;
  obs.enable = true;
};
```

To add a new host (e.g. MiniPC), create `systems/x86_64-linux/MiniPC/` and `homes/x86_64-linux/kbb@MiniPC/`, then enable only the modules you need.

## What's Installed

### System-level (NixOS)
- **Desktop:** KDE Plasma 6 + Wayland + SDDM
- **GPU:** NVIDIA proprietary drivers + nvidia-container-toolkit
- **Audio:** PipeWire (ALSA, PulseAudio, JACK)
- **Input:** fcitx5 with Lotus (Vietnamese input)
- **Services:** Tailscale, Cloudflared, SSH, Docker (GPU-enabled)
- **Filesystem:** btrfs root (zstd compression), NTFS data auto-mount
- **Packages:** git, vim, firefox, ntfs3g, pciutils, usbutils, lm_sensors, smartmontools

### User-level (home-manager)
- **Shell:** Fish + Starship prompt
- **Terminal:** Ghostty (catppuccin theme) + Zellij multiplexer
- **Browsers:** Firefox (system), Zen Browser (flake input)
- **Editor:** VS Code
- **AI Tools:** claude-code, opencode
- **Messaging:** Telegram Desktop
- **Media:** mpv player, OBS Studio
- **Security:** 1Password GUI
- **Git:** configured (tanhv90)

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable |
| `home-manager` | User environment management |
| `snowfall-lib` | Flake structure convention |
| `sops-nix` | Secret encryption (age-based) |
| `disko` | Declarative disk partitioning |
| `zen-browser` | Zen browser flake |
| `fcitx5-lotus` | Vietnamese input method |

## SOPS Secrets

- **Age public key:** `age1p8pa992p8n25ckvwlevrmzagexp4gl6qrngpg7uadkjzvwwv6d2sl0ws0u`
- **Private key location (on NixOS):** `/var/lib/sops/age/keys.txt` (on root `@` subvolume, NEVER commit)
- **Private key backup:** `secrets/age-keys.txt.backup` (gitignored)
- **Config:** `.sops.yaml` — encrypts files matching `secrets/*.yaml`

### How SOPS works at boot

1. NixOS mounts `/` (btrfs `@` subvolume)
2. `sops-install-secrets` reads the age key from `/var/lib/sops/age/keys.txt`, decrypts `secrets.yaml`, and places secrets at `/run/secrets-for-users/` (early, for user creation) and `/run/secrets/` (normal)
3. `neededForUsers = true` secrets are available at `/run/secrets-for-users/` **before** users are created — this is required for `hashedPasswordFile`
4. NixOS reads the password hash from `hashedPasswordFile` and writes it to `/etc/shadow`
5. SDDM login uses the password against `/etc/shadow`

### Important paths

| Path | Purpose |
|------|---------|
| `/var/lib/sops/age/keys.txt` | Age private key (must be on root subvolume, available early at boot) |
| `/run/secrets-for-users/<name>` | Early-decrypted secrets (`neededForUsers = true`) — used for user passwords |
| `/run/secrets/<name>` | Normal secrets — decrypted during system activation |

> **Do NOT** put the age key under `/home/` — it's on the `@home` subvolume which may not be mounted when SOPS runs early at boot.

### Edit secrets
```bash
sops secrets/secrets.yaml
```

### Setup on a new machine
1. Copy the age private key to `/var/lib/sops/age/keys.txt` (from backup)
2. `chmod 600 /var/lib/sops/age/keys.txt`
3. `nixos-rebuild switch --flake .#HostName`

## Usage

### Apply config
```bash
sudo nixos-rebuild switch --flake /path/to/nixos-desktop#Desktop
```

### Update all inputs
```bash
nix flake update
```

### Build without applying (dry run)
```bash
nix build .#nixosConfigurations.Desktop.config.system.build.toplevel
```

### Add a new module
1. Create `modules/home/<name>/default.nix` (or `modules/nixos/<name>/`)
2. Define `options.${namespace}.<name>.enable` and `config = mkIf ...`
3. Snowfall auto-discovers it — just enable in your host config

## TODO

- [x] Apply config to running system (`nixos-rebuild switch`)
- [x] Back up age private key to a safe location
- [x] Create first SOPS secret (git email, cloudflared token, etc.)
- [ ] Create GitHub repo and push
- [ ] Add more software as needed (neovim, etc.)
- [ ] Add MiniPC host configuration
- [ ] Consider LUKS + TPM disk encryption (requires reinstall)

## Known Issues

- **Chrome/Edge crash on NixOS 26.05** — `chrome_crashpad_handler: --database is required` causes SIGTRAP. This is a nixpkgs packaging issue. Use Firefox or Zen as workaround until fixed upstream.
- **NVMe device name swapping** — `nvme0n1`/`nvme1n1` can swap between boots. NTFS mount uses UUID (stable). Disko uses partlabels for fstab (stable). The disk attribute name `disk.nvme1n1` in `disk.nix` must match the partlabel prefix on disk (`disk-nvme1n1-*`) — do not rename it. The `device` path only matters at install time.
