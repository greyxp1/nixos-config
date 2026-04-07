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

        ({ modulesPath, pkgs, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            (modulesPath + "/profiles/all-hardware.nix")
          ];

          environment.systemPackages = [

            (wrappers.wrapperModules.niri.apply {
              inherit pkgs;
              package = inputs.niri.packages.${pkgs.system}.niri-stable;
              # Changed from "niri/config.kdl"
              "config.kdl".content = ''
                input {
                    keyboard { repeat-delay 200; repeat-rate 35; }
                }
                binds {
                    "Super+Return" { spawn "ghostty"; }
                    "Super+Q" { close-window; }
                    "Super+Shift+E" { quit; }
                }
                layout {
                    gutter 10
                    default-column-width { proportion 0.5; }
                }
              '';
            }).wrapper

            (wrappers.wrapperModules.ghostty.apply {
              inherit pkgs;
              package = pkgs.ghostty;
              # Changed from "ghostty/config"
              "config".content = ''
                theme = dark
                font-family = "JetBrainsMono Nerd Font"
                window-decoration = false
                cursor-style = block
              '';
            }).wrapper

            (wrappers.wrapperModules.git.apply {
              inherit pkgs;
              package = pkgs.git;
              # Changed from "git/config"
              "config".content = ''
                [user]
                  name = greyxp1
                  email = greyxp999@gmail.com
                [init]
                  defaultBranch = main
              '';
            }).wrapper

            # Standard packages
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
