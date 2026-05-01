{ inputs, ... }: {
  flake.nixosModules.boot = { pkgs, inputs, ... }: {
    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    systemd.network.wait-online.enable = false;

    boot = {
      supportedFilesystems = [ "btrfs" ];
      initrd.supportedFilesystems = [ "btrfs" ];

      loader = {
        efi.canTouchEfiVariables = true;
        timeout = 0;
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };
    };
  };
}
