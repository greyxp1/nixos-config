{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url             = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url  = "github:xddxdd/nix-cachyos-kernel/release";
    wrappers.url            = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";

    ghosttyWrappers = {
      url = "github:nouritsu/nix-wrapper-modules/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-cachyos-kernel, lanzaboote, helium, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        lanzaboote.nixosModules.lanzaboote
        (if builtins.pathExists ./bootloader.nix then ./bootloader.nix else {})
        ./hardware-configuration.nix
        ./configuration.nix
        ./modules/git.nix
        ./modules/niri.nix
        ./modules/ghostty.nix
        ./modules/noctalia-shell.nix
        ./modules/helium.nix

        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

          nix.settings = {
            trusted-users = [ "root" "@wheel" ];
            substituters = [
              "https://attic.xuyh0120.win/lantian"
              "https://cache.garnix.io"
            ];
            trusted-public-keys = [
              "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
              "cache.garnix.io:CTfPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            ];
          };

          environment.systemPackages = with pkgs; [
            vim
            curl
            tree
            bat
            sbctl
            fastfetch
          ];
        })
      ];
    };
  };
}
