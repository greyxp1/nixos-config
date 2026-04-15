{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.vm = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };
      modules = [
        # No lanzaboote — VMs use plain systemd-boot.
        inputs.home-manager.nixosModules.home-manager
        ./vm/hardware-configuration.nix
        ./vm/bootloader.nix
        ./vm/host.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
