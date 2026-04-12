# Defines the NixOS system configuration.
# Collects all nixosModules registered by other files in modules/ via inputs.self,
# so adding a new module file automatically includes it here.
{ inputs, withSystem, ... }: {
  systems = [ "x86_64-linux" ];

  flake.nixosConfigurations.greyxp1 = withSystem "x86_64-linux" ({ config, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        self          = inputs.self;
        flakePackages = config.packages;
      };
      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.home-manager.nixosModules.home-manager
        (if builtins.pathExists ./bootloader.nix then ./bootloader.nix else {})
        ./hardware-configuration.nix
      ] ++ builtins.attrValues inputs.self.nixosModules;
    }
  );
}
