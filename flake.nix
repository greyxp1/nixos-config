{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, wrappers, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        inputs.disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        ./modules/git.nix
        #./modules/ghostty.nix
        #./modules/niri.nix
      ];
    };
  };
}
