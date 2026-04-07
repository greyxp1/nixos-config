{
  description = "Basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    wrappers.url = "github:lassulus/wrappers";
    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = { self, nixpkgs, disko, wrappers, niri, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        disko.nixosModules.disko
        ./configuration.nix
        niri.nixosModules.niri

        ({ modulesPath, pkgs, lib, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            (modulesPath + "/profiles/all-hardware.nix")
          ];

          environment.systemPackages = [

            pkgs.vim
            pkgs.curl
            pkgs.tree
            pkgs.bat
          ];
        })
      ];
    };
  };
}
