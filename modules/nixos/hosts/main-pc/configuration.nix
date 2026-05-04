{ inputs, withSystem, ... }:
{
  flake.nixosConfigurations.main-pc = withSystem "x86_64-linux" (
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
            networking.hostName = "main-pc";
            custom.disk.device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B778557B959";
            boot = {
              initrd = {
                availableKernelModules = [
                  "nvme"
                  "xhci_pci"
                  "ahci"
                  "usb_storage"
                  "usbhid"
                  "sd_mod"
                ];
                systemd = {
                  enable = true;
                  network.wait-online.enable = false;
                };
              };
              kernelModules = [ "kvm-amd" ];
            };

            hardware.cpu.amd.updateMicrocode = true;
            services.xserver.videoDrivers = [ "nvidia" ];
            hardware.nvidia = {
              open = true;
              modesetting.enable = true;
            };

            boot = {
              loader.systemd-boot.enable = lib.mkForce false;
              lanzaboote = {
                autoGenerateKeys.enable = true;
                enable = true;
                pkiBundle = "/var/lib/sbctl";
                autoEnrollKeys = {
                  enable = true;
                  autoReboot = true;
                };
              };
            };

            system.activationScripts.sbctl-keys = {
              text = ''
                if [ ! -d /var/lib/sbctl ]; then
                  ${pkgs.sbctl}/bin/sbctl create-keys
                fi
              '';
            };

            environment.systemPackages = with pkgs; [ sbctl ];

            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;

              extraConfig.pipewire."99-lowlatency" = {
                "context.properties" = {
                  "default.clock.rate" = 48000;
                  "default.clock.quantum" = 128;
                  "default.clock.min-quantum" = 64;
                  "default.clock.max-quantum" = 512;
                };
              };

              wireplumber.extraConfig = lib.mkForce {
                "10-disable-hw-volume" = {
                  "monitor.alsa.rules" = [
                    {
                      matches = [ { "device.name" = "~alsa_card.*"; } ];
                      actions = {
                        update-props = {
                          "api.alsa.soft-mixer" = true;
                        };
                      };
                    }
                  ];
                };
              };
            };

            systemd.services = {
              set-alsa-levels = {
                description = "Set AT2005USB hardware mixer levels";
                after = [
                  "sound.target"
                  "pipewire.service"
                ];
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
            };
          }
        )
        inputs.lanzaboote.nixosModules.lanzaboote
      ]
      ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
