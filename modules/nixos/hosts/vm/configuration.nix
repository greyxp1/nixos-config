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
          { pkgs, lib, ... }:
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

            # seatd handles DRM device ownership — required for niri TTY backend in VM
            services.seatd = {
              enable = true;
              group = "seat";
            };

            # greetd must run niri-session after seatd is up
            systemd.services.greetd = {
              after = lib.mkForce [
                "multi-user.target"
                "seatd.service"
              ];
              wants = [ "seatd.service" ];
            };

            hardware.graphics.extraPackages = with pkgs; [ mesa ];

            services = {
              spice-vdagentd.enable = true;
              qemuGuest.enable = true;
            };

            environment = {
              sessionVariables = {
                WLR_NO_HARDWARE_CURSORS = "1";
                # tell libseat to use seatd explicitly
                LIBSEAT_BACKEND = "seatd";
              };
              systemPackages = with pkgs; [
                spice-vdagent
                mesa-demos # glxinfo/eglinfo for debugging
              ];
            };
          }
        )
      ]
      ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
