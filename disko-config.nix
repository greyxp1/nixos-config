{ lib, ... }:
let
  # Written by install.sh before disko is invoked — e.g. '"/dev/sda"'
  selectedDevice = import ./device.nix;
in {
  disko.devices.disk.nixos = {
    type   = "disk";
    device = selectedDevice;
    content = {
      type = "gpt";
      partitions = {
        # 1 MiB BIOS-boot partition — used by GRUB on BIOS/legacy systems,
        # harmlessly ignored on UEFI systems.
        boot = {
          size = "1M";
          type = "EF02";
        };
        # EFI System Partition — used on UEFI systems, ignored on BIOS.
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type       = "filesystem";
            format     = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type       = "filesystem";
            format     = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
