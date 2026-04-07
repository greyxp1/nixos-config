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
        wrappers.nixosModules.wrappers
        niri.nixosModules.niri

        ({ pkgs, ... }: {
          wrappers = {
            git = {
              enable = true;
              settings = {
                user = {
                  name = "greyxp1";
                  email = "greyxp999@gmail.com";
                };
                init = {
                  defaultBranch = "main";
                };
                pull.rebase = true;
              };
            };

            ghostty = {
              enable = true;
              settings = {
                theme = "dark";
                font-family = "JetBrainsMono Nerd Font";
                window-decoration = false;
                cursor-style = "block";
              };
            };

            niri = {
              enable = true;
              package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
              config = ''
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
            };
          };

          environment.systemPackages = with pkgs; [
            vim
            curl
            tree
            bat
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
