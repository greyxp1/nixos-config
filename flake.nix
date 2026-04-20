{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url            = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    flake-parts = {
      url                        = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url                    = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-modules = {
      url                    = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-plugins = {
      url   = "github:noctalia-dev/noctalia-plugins";
      flake = false;
    };

    ghosttyWrappers = {
      url                    = "github:nouritsu/nix-wrapper-modules/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url                    = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url                    = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    disko = {
      url                    = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ (inputs.import-tree ./modules) ];
    systems = [ "x86_64-linux" ];
  };
}
