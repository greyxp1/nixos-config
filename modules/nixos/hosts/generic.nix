{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.generic = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./generic/hardware-configuration.nix
        ./generic/bootloader.nix
        ./generic/host.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
