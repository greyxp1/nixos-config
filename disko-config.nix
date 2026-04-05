{ lib, ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault "/dev/sda"; #
        content = {
          type = "gpt";
          partitions = {
            # For systemd-boot on UEFI
            ESP = {
              size = "1G";
              type = "EF00"; #
              content = {
                type = "filesystem";
                format = "vfat"; #
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Btrfs partition for the OS
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  # The actual root (to be wiped in Tony's guide)
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # Persistent user data
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # The Nix store (read-only system files)
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # Optional: persistence layer if you do the "wipe on boot"
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
