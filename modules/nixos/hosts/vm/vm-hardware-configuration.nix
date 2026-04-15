# Generic hardware configuration for QEMU/KVM virtual machines.
# Works out-of-the-box with OVMF (UEFI) and virtio storage.
{ lib, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_blk" "sr_mod" "usb_storage" ];
  boot.initrd.kernelModules          = [ "virtio_gpu" ];
  boot.kernelModules                 = [ ];
  boot.extraModulePackages           = [ ];

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
