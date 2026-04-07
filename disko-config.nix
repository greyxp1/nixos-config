{ lib, device ? "/dev/nvme0n1", ... }: {
  disko.devices.disk.nixos = {
    type = "disk";
    device = lib.mkDefault device;
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            label = "BOOT";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            label = "ROOT";
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  };
}
