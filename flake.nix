{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    ghosttyWrappers.url = "github:nouritsu/nix-wrapper-modules/ghostty";
    ghosttyWrappers.inputs.nixpkgs.follows = "nixpkgs";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, cachyos-kernel, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        cachyos-kernel.nixosModules.cachyos-kernel
        inputs.disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        ./modules/git.nix
        ./modules/niri.nix
        ./modules/ghostty.nix
        ./modules/noctalia-shell.nix

        ({ pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            vim
            curl
            tree
            bat
          ];
        })
      ];
    };
  };
}
