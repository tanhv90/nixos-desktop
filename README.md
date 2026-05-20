# kbb's Desktop NixOS Configuration

NixOS flake using **snowfall-lib** — one repo, multiple hosts, modular config.

## Hardware

| Component | Detail |
|-----------|--------|
| CPU | Intel i7-13700F |
| GPU | NVIDIA RTX 3060 (proprietary, legacy_580) |
| RAM | 32GB DDR4 |
| Motherboard | ASUS TUF B660M |
| NVMe 0 | NixOS — 512M ESP + 32G swap + btrfs root (`@`, `@home`) |
| NVMe 1 | NTFS data → `/mnt/data` (UUID: `4F39D88A0D52E8C5`) |

> NVMe device names can swap between boots. NTFS mount uses UUID. Disko uses partlabels for fstab (stable). The `device` path only matters at install time.

## Architecture

```
flake.nix          → defines inputs, snowfall-lib discovers the rest
├── systems/       → one folder per host (NixOS config)
│   └── Desktop/   → hardware.nix + disk.nix + default.nix (enables modules)
├── homes/         → one folder per user@host (home-manager)
│   └── kbb@Desktop/
├── modules/
│   ├── nixos/     → reusable system modules (services, drivers, fonts)
│   └── home/      → reusable user modules (shell, editors, apps, toolchains)
└── secrets/       → SOPS-encrypted (age key)
```

**Key idea:** Create a module once in `modules/`, then toggle it per-host with `kbb.<name>.enable = true`. Snowfall auto-discovers everything under `systems/`, `homes/`, and `modules/` — no imports needed.

The host config wires the essentials: bootloader (systemd-boot), display (KDE Plasma 6 + Wayland + SDDM), GPU (NVIDIA + nvidia-container-toolkit), audio (PipeWire), secrets (SOPS), and the user account (immutable, hashed password from SOPS, fish shell).

## Stack Summary

| Layer | What |
|-------|------|
| **OS** | NixOS unstable, systemd-boot, btrfs (zstd) |
| **Display** | KDE Plasma 6, SDDM (Wayland), Wayland-native Chromium via `NIXOS_OZONE_WL` |
| **GPU** | NVIDIA legacy_580 (explicit-sync), nvidia-container-toolkit |
| **Audio** | PipeWire (ALSA, PulseAudio, JACK) |
| **Network** | NetworkManager, Tailscale (exit node), Cloudflare tunnel, SSH |
| **Input** | fcitx5 + Lotus (Vietnamese) |
| **Secrets** | SOPS (age), decrypted at boot before user creation |
| **User env** | Fish + Starship, Ghostty + Zellij, VS Code |
| **Dev tools** | Node.js 25 + bun, Python 3.12 + uv, fd + ripgrep, lazydocker |
| **Apps** | 1Password, Zen Browser, Telegram, Discord, OBS, mpv, ONLYOFFICE, RustDesk |
| **AI** | claude-code, opencode |
| **Data** | `/mnt/data` → `~/external` (out-of-store symlink) |

## For a New Host

Create `systems/x86_64-linux/<Host>/` and `homes/x86_64-linux/kbb@<Host>/`, enable only the modules you need. No other wiring required.

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable |
| `home-manager` | User environment |
| `snowfall-lib` | Flake structure + auto-discovery |
| `sops-nix` | Secret encryption |
| `disko` | Declarative partitioning |
| `zen-browser` | Zen browser flake |
| `fcitx5-lotus` | Vietnamese input |

## SOPS Secrets

- **Age public key:** `age1p8pa992p8n25ckvwlevrmzagexp4gl6qrngpg7uadkjzvwwv6d2sl0ws0u`
- **Private key:** `/var/lib/sops/age/keys.txt` (on root `@` subvolume — NEVER commit)
- **Backup:** `secrets/age-keys.txt.backup` (gitignored)

### Boot sequence

1. `/` mounts (btrfs `@` subvolume)
2. SOPS reads age key from `/var/lib/sops/age/keys.txt`, decrypts `secrets.yaml`
3. `neededForUsers` secrets land at `/run/secrets-for-users/` (available **before** user creation)
4. NixOS reads `hashedPasswordFile` → writes `/etc/shadow` → SDDM login

> Do **NOT** put the age key under `/home/` — `@home` may not be mounted when SOPS runs.

```bash
sops secrets/secrets.yaml            # edit secrets
```

### New machine setup

```bash
cp <backup> /var/lib/sops/age/keys.txt
chmod 600 /var/lib/sops/age/keys.txt
sudo nixos-rebuild switch --flake /path/to/nixos-desktop#Desktop
```

## Usage

```bash
sudo nixos-rebuild switch --flake .#Desktop    # apply
nix flake update                                # update all inputs
nix build .#nixosConfigurations.Desktop.config.system.build.toplevel  # dry run
```

## TODO

- [x] Applied to running system
- [x] Age key backed up
- [x] SOPS secrets created
- [x] GitHub repo (tanhv90/nixos-desktop)
- [ ] MiniPC host config
- [ ] LUKS + TPM disk encryption

## Known Issues

- **Chrome/Edge crash on NixOS 26.05** — `chrome_crashpad_handler: --database is required` causes SIGTRAP. Use Firefox or Zen.
- **NVMe device name swapping** — `nvme0n1`/`nvme1n1` can flip between boots. NTFS mount uses UUID (stable). Disko uses partlabels for fstab (stable). The disk attribute name `disk.nvme1n1` in `disk.nix` must match the partlabel prefix on disk (`disk-nvme1n1-*`).
