{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.vm = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };

      modules = [
        ({ pkgs, ... }: {
          networking.hostName = "vm";

          boot.kernelPackages = pkgs.linuxPackages_latest;

          services.spice-vdagentd.enable = true;
          services.qemuGuest.enable      = true;

          environment.systemPackages = with pkgs; [ spice-vdagent ];

          boot.loader.systemd-boot.enable      = true;
          boot.loader.efi.canTouchEfiVariables = true;
        })
        inputs.home-manager.nixosModules.home-manager
        ./_hardware-configuration.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
