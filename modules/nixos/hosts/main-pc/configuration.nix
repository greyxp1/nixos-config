{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.main-pc = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };

      modules = [
        ({ pkgs, lib, ... }: {
          # ── CachyOS kernel ─────────────────────────────────────────────────────
          nixpkgs.overlays    = [ inputs.nix-cachyos-kernel.overlays.pinned ];
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

          # ── Extra binary caches for CachyOS packages ────────────────────────────
          nix.settings = {
            extra-substituters = [
              "https://attic.xuyh0120.win/lantian"
              "https://cache.garnix.io"
            ];
            extra-trusted-public-keys = [
              "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
              "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            ];
          };

          # ── Nvidia ─────────────────────────────────────────────────────────────
          services.xserver.videoDrivers = [ "nvidia" ];

          hardware.nvidia = {
            open               = true;
            modesetting.enable = true;
          };

          # ── Boot ───────────────────────────────────────────────────────────────
          boot = {
            loader = {
              efi.canTouchEfiVariables = true;
              timeout = 0;
              systemd-boot = {
                enable = lib.mkForce false;
                configurationLimit = 10;
              };
            };

            lanzaboote = {
              autoGenerateKeys.enable = true;
              enable    = true;
              pkiBundle = "/var/lib/sbctl";
              autoEnrollKeys = {
                enable     = true;
                autoReboot = true;
              };
            };

            initrd.systemd = {
              enable = true;
              network.wait-online.enable = false;
            };
          };

          # Don't block on network at boot
          systemd.network.wait-online.enable = false;

          # ── Secure boot keys ───────────────────────────────────────────────────
          system.activationScripts.sbctl-keys = {
            text = ''
              if [ ! -d /var/lib/sbctl ]; then
                ${pkgs.sbctl}/bin/sbctl create-keys
              fi
            '';
          };

          environment.systemPackages = [ pkgs.sbctl ];
        })
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.home-manager.nixosModules.home-manager
        inputs.catppuccin.nixosModules.catppuccin
        ./_hardware-configuration.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
