{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    niri.url = "github:YaLTeR/niri";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./parts/niri.nix
        #./parts/ghostty.nix
        ./parts/git.nix
      ];

      flake = {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            inputs.disko.nixosModules.disko
            ./configuration.nix
            ({ pkgs, ... }: {
              services.displayManager.sessionPackages = [ self.packages."x86_64-linux".niri-custom ];

              environment.systemPackages = [
                #self.packages."x86_64-linux".ghostty-custom
                self.packages."x86_64-linux".git-custom
                pkgs.vim
              ];

              programs.niri.enable = true;
              programs.niri.package = self.packages."x86_64-linux".niri-custom;
            })
          ];
        };
      };
    };
}
