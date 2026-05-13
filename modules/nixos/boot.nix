{ inputs, ... }:
{
  flake.nixosModules.boot =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
      boot.kernelPackages = pkgs.lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest;

      systemd.network.wait-online.enable = false;

      boot = {
        supportedFilesystems = [ "btrfs" ];
        initrd.supportedFilesystems = [ "btrfs" ];

        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
          timeout = 0;
        };
      };
    };
}
