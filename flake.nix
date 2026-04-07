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

          # Niri via its NixOS module so the session file is registered for ly.
          # The wrapped package bakes the config in via the NIRI_CONFIG env var.
          programs.niri = {
            enable = true;
            package = lib.mkForce (wrappers.lib.wrapPackage {
              inherit pkgs;
              package = inputs.niri.packages.${pkgs.system}.niri-stable;
              env.NIRI_CONFIG = "${pkgs.writeText "niri-config.kdl" ''
                input {
                    keyboard { repeat-delay 200; repeat-rate 35; }
                }
                binds {
                    Super+Return { spawn "ghostty"; }
                    Super+Q { close-window; }
                    Super+Shift+E { quit; }
                }
                layout {
                    gaps 10
                    default-column-width { proportion 0.5; }
                }
              ''}";
            });
          };

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
