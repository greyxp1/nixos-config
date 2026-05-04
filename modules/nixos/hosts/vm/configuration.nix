{ inputs, withSystem, ... }:
{
  flake.nixosConfigurations.vm = withSystem "x86_64-linux" (
    { config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };

      modules = [
        (
          { pkgs, ... }:
          {
            networking.hostName = "vm";
            custom.disk.device = "/dev/vda";
            boot.initrd.availableKernelModules = [
              "virtio_pci"
              "virtio_blk"
              "virtio_scsi"
              "ahci"
              "sd_mod"
              "virtio_gpu"
            ];
            boot.kernelModules = [
              "kvm-amd"
              "kvm-intel"
              "virtio_gpu"
            ];

            hardware.graphics.extraPackages = with pkgs; [ mesa ];

            services = {
              spice-vdagentd.enable = true;
              qemuGuest.enable = true;
            };

            environment = {
              sessionVariables = {
                WLR_NO_HARDWARE_CURSORS = "1";
              };
              systemPackages = [
                pkgs.spice-vdagent
                pkgs.open-vm-tools
              ];
            };
          }
        )
      ]
      ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
