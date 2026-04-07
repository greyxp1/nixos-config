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
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        disko.nixosModules.disko
        ./configuration.nix
        niri.nixosModules.niri

        ({ pkgs, ... }:
          let
            # Access the wrapper library directly from inputs
            wlib = wrappers.lib;
          in {
            environment.systemPackages = [
              # 1. Wrapped Git
              (wlib.wrapPackage {
                inherit pkgs;
                package = pkgs.git;
                # Equivalent to HM 'settings'
                env.GIT_CONFIG_GLOBAL = pkgs.writeText "gitconfig" ''
                  [user]
                    name = greyxp1
                    email = greyxp999@gmail.com
                  [init]
                    defaultBranch = main
                  [pull]
                    rebase = true
                '';
              })

              # 2. Wrapped Ghostty
              (wlib.wrapPackage {
                inherit pkgs;
                package = pkgs.ghostty;
                env.GHOSTTY_CONFIG_FILE = pkgs.writeText "ghostty-config" ''
                  theme = dark
                  font-family = "JetBrainsMono Nerd Font"
                  window-decoration = false
                  cursor-style = block
                '';
              })

              # 3. Wrapped Niri
              (wlib.wrapPackage {
                inherit pkgs;
                package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
                env.NIRI_CONFIG = pkgs.writeText "niri-config.kdl" ''
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
              })

              # Standard System Tools
              pkgs.vim
              pkgs.curl
              pkgs.tree
              pkgs.bat
            ];
          })

        ({ modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            (modulesPath + "/profiles/all-hardware.nix")
          ];
        })
      ];
    };
  };
}
