{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.main-pc = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        flakePackages = config.packages;
      };
      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.home-manager.nixosModules.home-manager
        ./main-pc/hardware-configuration.nix
        ./main-pc/bootloader.nix
        ./main-pc/host.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
