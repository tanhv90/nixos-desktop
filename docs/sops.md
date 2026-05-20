# SOPS Secrets

## Overview

Secrets (passwords, API tokens, auth keys) are encrypted with **age** and committed to the repo at `secrets/secrets.yaml`. The age private key lives on the NixOS root subvolume and is **never committed**.

## Key Files

| File | Purpose | Committed? |
|------|---------|------------|
| `.sops.yaml` | Age public key + encryption rules | yes |
| `secrets/secrets.yaml` | Encrypted secrets | yes |
| `secrets/age-keys.txt.backup` | Age private key backup | no (gitignored) |
| `/var/lib/sops/age/keys.txt` | Age private key (on NixOS) | no (root subvolume) |

## Boot Sequence

1. `/` mounts (btrfs `@` subvolume)
2. SOPS reads age key from `/var/lib/sops/age/keys.txt`
3. Decrypts `secrets/secrets.yaml`
4. `neededForUsers = true` secrets land at `/run/secrets-for-users/<name>` — available **before** user creation
5. NixOS creates users → reads `hashedPasswordFile` → writes `/etc/shadow`
6. System activation → normal secrets land at `/run/secrets/<name>`
7. SDDM login → password checked against `/etc/shadow`

> **Critical:** The age key must be on the root `@` subvolume (`/var/lib/sops/age/keys.txt`), **not** under `/home/`. The `@home` subvolume may not be mounted when SOPS runs at early boot.

## Secret Paths

| Secret name | `neededForUsers` | Target path |
|---|---|---|
| `user/kbb_hashed_password` | `true` | `/run/secrets-for-users/user/kbb_hashed_password` |
| `cloudflared/tunnel_token` | `false` | `/run/secrets/cloudflared/tunnel_token` |
| `tailscale/auth_key` | `false` | `/run/secrets/tailscale/auth_key` |

## Editing Secrets

From a running NixOS system:

```bash
sops secrets/secrets.yaml
```

The age key at `/var/lib/sops/age/keys.txt` is used automatically.

## New Machine Key Setup

```bash
mkdir -p /mnt/var/lib/sops/age
cp secrets/age-keys.txt.backup /mnt/var/lib/sops/age/keys.txt
chmod 600 /mnt/var/lib/sops/age/keys.txt
```

Done once per machine, before the first `nixos-install` or `nixos-rebuild switch`.
