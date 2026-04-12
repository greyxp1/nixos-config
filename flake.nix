{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url            = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
    systems = [ "x86_64-linux" ];

    # Auto-import all flake-parts modules from modules/flake/.
    imports = [ (inputs.import-tree ./modules/flake) ];

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
          ./modules/nixos/configuration.nix
          ./modules/nixos/nixpkgs.nix
          ./modules/nixos/git.nix
          ./modules/nixos/niri.nix
          ./modules/nixos/ghostty.nix
          ./modules/nixos/noctalia-shell.nix
          inputs.self.nixosModules.helium
          inputs.self.nixosModules.zed
        ];
      }
    );
  });
}
