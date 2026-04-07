{
  description = "Basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";

    #home-manager.url = "github:nix-community/home-manager";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, niri, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        disko.nixosModules.disko
        ./configuration.nix
        niri.nixosModules.niri

        ({ modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            (modulesPath + "/profiles/all-hardware.nix")
          ];
        })

        #home-manager.nixosModules.home-manager
        #{
        #  home-manager = {
        #    useGlobalPkgs = true;
        #    useUserPackages = true;
        #    extraSpecialArgs = { inherit inputs; };
        #    users.grey = imports ./home.nix
        #    };
        #  };
        #}
      ];
    };
  };
}
