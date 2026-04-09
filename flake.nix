{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    ghosttyWrappers.url = "github:nouritsu/nix-wrapper-modules/ghostty";
    ghosttyWrappers.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-cachyos-kernel, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        inputs.disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        ./modules/git.nix
        ./modules/niri.nix
        ./modules/ghostty.nix
        ./modules/noctalia-shell.nix

        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ];
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

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
