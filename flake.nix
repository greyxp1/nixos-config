{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url            = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, config, ... }: {
    systems = [ "x86_64-linux" ];

    # App modules declare their own perSystem.packages and flake.nixosModules
    imports = [
      ./modules/helium.nix
      ./modules/zed.nix
    ];

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
          (if builtins.pathExists ./bootloader.nix then ./bootloader.nix else {})
          ./hardware-configuration.nix
          ./configuration.nix
          ./modules/nixpkgs.nix
          ./modules/git.nix
          ./modules/niri.nix
          ./modules/ghostty.nix
          ./modules/noctalia-shell.nix
          inputs.self.nixosModules.helium
          inputs.self.nixosModules.zed
        ];
      }
    );
  });
}
