{
  description = "Basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          ./configuration.nix
          ({ modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/scan/not-detected.nix")
              (modulesPath + "/profiles/all-hardware.nix")
            ];
          })
        ];
      };
    };
  };
}
