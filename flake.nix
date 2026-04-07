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
            # Wrapped Ghostty — prepends --config-file so users can still pass
            # their own flags and the baked config is always loaded.
            (wrappers.lib.wrapPackage {
              inherit pkgs;
              package = pkgs.ghostty;
              flags."--config-file" = "${pkgs.writeText "ghostty-config" ''
                theme = dark
                font-family = JetBrainsMono Nerd Font
                window-decoration = false
                cursor-style = block
              ''}";
            })

            # Wrapped Git — GIT_CONFIG_GLOBAL points to the baked config,
            # while still respecting per-repo .git/config as usual.
            (wrappers.lib.wrapPackage {
              inherit pkgs;
              package = pkgs.git;
              env.GIT_CONFIG_GLOBAL = "${pkgs.writeText "gitconfig" ''
                [user]
                  name = greyxp1
                  email = greyxp999@gmail.com
                [init]
                  defaultBranch = main
              ''}";
            })

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
