# Fresh Install (New Machine)

## Prerequisites

- NixOS installer ISO (unstable or 24.11+)
- This flake repo (clone from GitHub or copy from USB)
- SOPS age private key backup (`secrets/age-keys.txt.backup` in the repo — gitignored)

## Step by Step

### 1. Boot NixOS installer

Boot the ISO, connect to network, open a terminal.

### 2. Get the flake

```bash
git clone https://github.com/tanhv90/nixos-desktop.git
cd nixos-desktop
```

### 3. Partition & format the disk

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko systems/x86_64-linux/Desktop/disk.nix
```

This creates a GPT layout on `/dev/nvme0n1`:
- `p1` — 512M ESP (VFAT) → `/boot`
- `p2` — 32G swap
- `p3` — btrfs root with `@` and `@home` subvolumes

Partitions are labeled with `disk-nvme1n1-*` prefix (used by fstab). Btrfs filesystem label is `nixos`.

### 4. Mount everything

```bash
sudo mount -o subvol=@,compress=zstd,noatime /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/home /mnt/boot
sudo mount -o subvol=@home,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/home
sudo mount /dev/disk/by-partlabel/disk-nvme1n1-ESP /mnt/boot
```

### 5. Place age key

```bash
sudo mkdir -p /mnt/var/lib/sops/age
sudo cp secrets/age-keys.txt.backup /mnt/var/lib/sops/age/keys.txt
sudo chmod 600 /mnt/var/lib/sops/age/keys.txt
```

This must be done **before** `nixos-install` so SOPS can decrypt the user password hash during user creation.

### 6. Install NixOS

```bash
sudo cp -r . /mnt/tmp/nixos-desktop
sudo nixos-install --flake /mnt/tmp/nixos-desktop#Desktop
sudo reboot
```

After reboot you'll be greeted by SDDM. Log in with the password you set via SOPS.
