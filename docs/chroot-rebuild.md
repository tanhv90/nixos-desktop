# Rebuilding from Live ISO (chroot)

Use this when the running system is broken, `nixos-rebuild` fails, or after a kernel/driver change that prevents booting.

## Script: `chroot-rebuild.sh`

The script at the repo root does the heavy lifting:

1. Mounts btrfs subvolumes and ESP to `/mnt/nixos`
2. Copies the flake into the chroot
3. Runs `nixos-rebuild boot` from inside the chroot
4. Cleans up

The script assumes:
- The flake source is on the NTFS data drive at `/run/media/kbb/4F39D88A0D52E8C5/nixos-desktop`
- Btrfs label is `nixos`
- ESP partlabel is `disk-nvme1n1-ESP`

## Usage

Boot the NixOS installer ISO, mount the NTFS data drive, then:

```bash
# Mount NTFS data drive (this flake lives on it)
sudo mkdir -p /run/media/kbb/4F39D88A0D52E8C5
sudo mount -t ntfs3 /dev/disk/by-uuid/4F39D88A0D52E8C5 /run/media/kbb/4F39D88A0D52E8C5

# Run the rebuild
sudo /run/media/kbb/4F39D88A0D52E8C5/nixos-desktop/chroot-rebuild.sh

# Reboot into the new build
sudo reboot
```

> Uses `nixos-rebuild boot` (not `switch`) since we're in a chroot, not the running system. The new generation is added to the bootloader and takes effect on next reboot.
