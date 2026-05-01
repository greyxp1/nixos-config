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
          networking.hostName = "main-pc";

          # ── Disk ───────────────────────────────────────────────────────────────
          # Only needed for manual disko re-runs. Install script overrides this.
          custom.disk.device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B778557B959";

          # ── Hardware ───────────────────────────────────────────────────────────
          boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
          boot.kernelModules                 = [ "kvm-amd" ];
          hardware.cpu.amd.updateMicrocode   = true;

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
            supportedFilesystems        = [ "btrfs" ];
            initrd.supportedFilesystems = [ "btrfs" ];

            loader = {
              efi.canTouchEfiVariables = true;
              timeout                  = 0;
              systemd-boot = {
                enable             = lib.mkForce false;
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
              enable                     = true;
              network.wait-online.enable = false;
            };

            #consoleLogLevel = 0;
            #kernelParams    = [ "quiet" "udev.log_level=0" "rd.systemd.show_status=false" "rd.udev.log_level=0" ];
          };

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

          # ── Audio (Specific to main-pc) ──────────────────────────────────────────
          services.pipewire = {
            enable = true;
            alsa.enable  = true;
            pulse.enable = true;
            wireplumber.extraConfig = lib.mkForce {
              "10-disable-hw-volume" = {
                "monitor.alsa.rules" = [
                  {
                    matches = [{ "device.name" = "~alsa_card.*"; }];
                    actions = {
                      update-props = { "api.alsa.soft-mixer" = true; };
                    };
                  }
                ];
              };
            };
          };

          systemd.services.set-alsa-levels = {
            description = "Set AT2005USB hardware mixer levels";
            after = [ "sound.target" "pipewire.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
              ExecStart = [
                "${pkgs.alsa-utils}/bin/amixer -c AT2005USB sset Speaker 100%"
                "${pkgs.alsa-utils}/bin/amixer -c AT2005USB sset Mic playback 0%"
                "${pkgs.alsa-utils}/bin/amixer -c AT2005USB sset Mic capture 100%"
              ];
              RemainAfterExit = true;
            };
          };
        })
        inputs.lanzaboote.nixosModules.lanzaboote
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
