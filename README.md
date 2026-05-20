# kbb's Desktop NixOS Configuration

NixOS flake using **snowfall-lib** — one repo, multiple hosts, modular config.

## Hardware

| Component | Detail |
|-----------|--------|
| CPU | Intel i7-13700F |
| GPU | NVIDIA RTX 3060 (proprietary, legacy_580) |
| RAM | 32GB DDR4 |
| NVMe 0 | NixOS — 512M ESP + 32G swap + btrfs root (`@`, `@home`) |
| NVMe 1 | NTFS data → `/mnt/data` (UUID: `4F39D88A0D52E8C5`) |

> NVMe names can swap between boots. NTFS mount uses UUID. Disko uses partlabels for fstab (stable).

## Architecture

```
flake.nix          → defines inputs, snowfall-lib discovers the rest
├── systems/       → one folder per host (NixOS config)
├── homes/         → one folder per user@host (home-manager)
├── modules/
│   ├── nixos/     → reusable system modules (7)
│   └── home/      → reusable user modules (20)
└── secrets/       → SOPS-encrypted (age key)
```

**Key idea:** Create a module once in `modules/`, toggle it per-host with `kbb.<name>.enable = true`. Snowfall auto-discovers — no imports.

## Stack Summary

| Layer | What |
|-------|------|
| **OS** | NixOS unstable, systemd-boot, btrfs (zstd) |
| **Display** | KDE Plasma 6, SDDM (Wayland) |
| **GPU** | NVIDIA legacy_580 + nvidia-container-toolkit |
| **Audio** | PipeWire (ALSA, PulseAudio, JACK) |
| **Network** | NetworkManager, Tailscale (exit node), Cloudflare tunnel, SSH |
| **Input** | fcitx5 + Lotus (Vietnamese) |
| **Secrets** | SOPS (age), decrypted at boot before user creation |
| **User env** | Fish + Starship, Ghostty + Zellij, VS Code |
| **Dev tools** | Node.js 25 + bun, Python 3.12 + uv, fd + ripgrep, lazydocker |
| **Apps** | 1Password, Zen Browser, Telegram, Discord, OBS, mpv, ONLYOFFICE, RustDesk |
| **AI** | claude-code, opencode |
| **Data** | `/mnt/data` → `~/external` (out-of-store symlink) |

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

## Usage

```bash
sudo nixos-rebuild switch --flake .#Desktop    # apply config
nix flake update                                # update all inputs
```

## For a New Host

Create `systems/x86_64-linux/<Host>/` and `homes/x86_64-linux/kbb@<Host>/`, enable only the modules you need.

## Docs

- [Fresh install](docs/install.md) — step-by-step for a new machine
- [SOPS secrets](docs/sops.md) — boot sequence, paths, key management
- [Chroot rebuild](docs/chroot-rebuild.md) — rebuild from live ISO when the system won't boot

## Known Issues

- **Chrome/Edge crash on NixOS 26.05** — `chrome_crashpad_handler: --database is required` causes SIGTRAP. Use Firefox or Zen.
- **NVMe name swapping** — `nvme0n1`/`nvme1n1` can flip. NTFS uses UUID. Disko uses partlabels. The disk attribute name in `disk.nix` must match the partlabel prefix on disk.
