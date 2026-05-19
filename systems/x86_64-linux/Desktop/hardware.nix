# Hardware configuration for Desktop
# Intel i7-13700F, NVIDIA RTX 3060, ASUS TUF B660M, 32GB DDR4
#
# Disk layout:
#   /dev/nvme0n1 (NixOS):
#     p1  512MB   ESP   -> /boot
#     p2  32GB    swap
#     p3  rest    btrfs -> / (@), /home (@home)
#
#   /dev/nvme1n1 (Data):
#     p1  954GB   NTFS  -> /mnt/data
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
