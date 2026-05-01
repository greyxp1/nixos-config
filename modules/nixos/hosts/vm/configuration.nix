{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.vm = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };

      modules = [
        ({ pkgs, ... }: {
          networking.hostName = "vm";
          custom.disk.device = "/dev/vda";
          boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "ahci" "sd_mod" ];
          boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

          services.spice-vdagentd.enable = true;
          services.qemuGuest.enable = true;
          environment.systemPackages = [
            pkgs.spice-vdagent
            pkgs.open-vm-tools
          ];
        })
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
