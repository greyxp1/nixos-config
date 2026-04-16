{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.generic = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };

      modules = [
        ({ pkgs, ... }: {
          networking.hostName = "generic";

          boot.kernelPackages = pkgs.linuxPackages_latest;

          boot.loader.systemd-boot.enable      = true;
          boot.loader.efi.canTouchEfiVariables = true;
        })
        inputs.home-manager.nixosModules.home-manager
        ./_hardware-configuration.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
