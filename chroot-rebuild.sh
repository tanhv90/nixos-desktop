#!/bin/bash
set -e

NIXOS_ROOT=/mnt/nixos
BTRFS_DEV=/dev/disk/by-label/nixos
ESP_DEV=/dev/disk/by-partlabel/disk-nvme1n1-ESP
FLAKE_SRC=/run/media/kbb/4F39D88A0D52E8C5/nixos-desktop

# Cleanup any previous mounts
umount -R "$NIXOS_ROOT" 2>/dev/null || true

# Mount btrfs subvolumes and ESP
mkdir -p "$NIXOS_ROOT"
mount -o subvol=@,compress=zstd,noatime "$BTRFS_DEV" "$NIXOS_ROOT"
mount -o subvol=@home,compress=zstd,noatime "$BTRFS_DEV" "$NIXOS_ROOT/home"
mount "$ESP_DEV" "$NIXOS_ROOT/boot"

# Copy flake into chroot (since bind mounts get messy)
rm -rf "$NIXOS_ROOT/tmp/nixos-desktop"
cp -r "$FLAKE_SRC" "$NIXOS_ROOT/tmp/nixos-desktop"

# Bind-mount system dirs (skip /run to keep NixOS symlinks)
mount --bind /dev "$NIXOS_ROOT/dev"
mount -t devpts devpts "$NIXOS_ROOT/dev/pts"
mount --bind /proc "$NIXOS_ROOT/proc"
mount --bind /sys "$NIXOS_ROOT/sys"

# Chroot and rebuild
chroot "$NIXOS_ROOT" /bin/sh -c '
  export PATH=/nix/var/nix/profiles/system/sw/bin:/nix/var/nix/profiles/system/sw/sbin:$PATH
  nixos-rebuild boot --flake /tmp/nixos-desktop#Desktop --option sandbox false
'

# Cleanup
rm -rf "$NIXOS_ROOT/tmp/nixos-desktop"
umount -R "$NIXOS_ROOT"

echo "Done! Reboot and log in with your new password."
