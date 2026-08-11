# kbb's Desktop

NixOS flake — one repo, modular config. Auto-discovers `modules/{nixos,home}/*`.

## Hardware

| Component | Detail |
|-----------|--------|
| CPU | Intel i7-13700F |
| GPU | NVIDIA RTX 3060 (proprietary, legacy_580) |
| RAM | 32GB DDR4 |
| Disk | NVMe 0: ESP + swap + btrfs (`@`, `@home`) — NVMe 1: NTFS → `/mnt/data` |

## Structure

```
flake.nix
├── systems/     → one folder per host (NixOS)
├── homes/       → one folder per user@host (home-manager)
├── modules/
│   ├── nixos/   → system modules (auto-loaded)
│   └── home/    → user modules (auto-loaded)
├── overlays/    → package overlays (opencode)
└── secrets/     → SOPS-encrypted (age)
```

Modules are auto-discovered — no manual imports. Each module exposes `kbb.<name>.enable = true`.

## AI Tools

All from `github:numtide/llm-agents.nix`. Each tool has its own toggle under the master `ai-tools.enable`:

```nix
kbb.ai-tools = {
  enable = true;
  droid.enable = true;             # Droid + daemon
  pi.enable = true;                # Pi
  antigravity-cli.enable = true;   # Antigravity CLI
  claude-code.enable = true;       # Claude Code
  daemon.enable = true;            # Droid background service
  daemon.remoteAccess = true;
};
```

## Flake Reference (vanilla, no snowfall-lib)

```nix
{
  description = "kbb's Desktop NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ... other inputs follow nixpkgs ...
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    namespace = "kbb";
  in {
    nixosConfigurations.Desktop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs namespace; };
      modules = [
        ./systems/x86_64-linux/Desktop
        ./modules/nixos                      # auto-loads all nixos modules
        { nixpkgs.config.allowUnfree = true; }
        { nixpkgs.overlays = [ (import ./overlays/opencode { }) ]; }

        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [ ./modules/home ];  # auto-loads all home modules
            users.kbb = import ./homes/x86_64-linux/kbb@Desktop;
            extraSpecialArgs = { inherit inputs namespace; };
          };
        }
      ];
    };
  };
}
```

## Usage

```bash
sudo nixos-rebuild switch --flake .#Desktop
nix flake update
```

## For a New Host

Add `systems/x86_64-linux/<Host>/` and `homes/x86_64-linux/kbb@<Host>/`, enable only the modules you need in the host config.

## Docs

- [Fresh install](docs/install.md)
- [SOPS secrets](docs/sops.md)
- [Chroot rebuild](docs/chroot-rebuild.md)
