# Portable hardware configuration — uses disk labels so it works on any
# machine where the installer formatted partitions with the standard labels
# (NIXBOOT / nixos).  Replace this file with the output of
# 'nixos-generate-config --show-hardware-config' if you need host-specific
# kernel modules or microcode.
{ lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "virtio_pci" "virtio_blk"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules        = [ ];
  boot.extraModulePackages  = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device  = "/dev/disk/by-label/NIXBOOT";
    fsType  = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices          = [];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
