{
  description = "Refactored flake using BirdeeHub wrapper modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Using BirdeeHub as requested
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

    # Niri source for the underlying package
    niri.url = "github:YaLTeR/niri";
  };

  outputs = { self, nixpkgs, disko, wrappers, niri, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        # 1. Wrapped Niri: Merged current and commented-out settings
        niri-custom = wrappers.wrappers.${system}.niri.wrap {
          inherit pkgs;
          package = niri.packages.${system}.niri;
          settings = {
            input = {
              keyboard = {
                xkb.layout = "us";
                repeat-delay = 200;
                repeat-rate = 35;
              };
              touchpad.tap = true;
            };

            outputs."DP-1" = {
              mode = "2560x1440@144";
              position = { x = 0; y = 0; };
            };

            layout = {
              gaps = 10;
              default-column-width = { proportion = 0.5; };
            };

            binds = {
              "Mod+Return".action.spawn = [ "ghostty" ];
              "Mod+Q".action.close-window = [];
              "Mod+Shift+E".action.quit = [];
            };
          };
        };

        # 2. Wrapped Ghostty
        ghostty-custom = wrappers.wrappers.${system}.ghostty.wrap {
          inherit pkgs;
          settings = {
            theme = "dark";
            font-family = "JetBrainsMono Nerd Font";
            window-decoration = false;
            cursor-style = "block";
          };
        };

        # 3. Wrapped Git
        git-custom = wrappers.wrappers.${system}.git.wrap {
          inherit pkgs;
          settings = {
            user = {
              name = "greyxp1";
              email = "greyxp999@gmail.com";
            };
            init.defaultBranch = "main";
          };
        };
      };

      nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./configuration.nix

          ({ pkgs, ... }: {
            # Added as a session package for your display manager
            services.displayManager.sessionPackages = [ self.packages.${system}.niri-custom ];

            environment.systemPackages = [
              # Using the wrapped packages defined above
              self.packages.${system}.ghostty-custom
              self.packages.${system}.git-custom

              pkgs.vim
              pkgs.curl
              pkgs.tree
              pkgs.bat
            ];

            # Ensure the niri service/polkit settings from the input are available
            programs.niri.enable = true;
            programs.niri.package = self.packages.${system}.niri-custom;
          })
        ];
      };
    };
}
