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
            wm = inputs.wrappers.wrapperModules;
          in {
            environment.systemPackages = [

              (wm.niri.apply {
                inherit pkgs;
                package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
                "niri/config.kdl".content = ''
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

              (wm.ghostty.apply {
                inherit pkgs;
                "ghostty/config".content = ''
                  theme = dark
                  font-family = "JetBrainsMono Nerd Font"
                  window-decoration = false
                  cursor-style = block
                '';
              }).wrapper

              (wm.git.apply {
                inherit pkgs;
                "git/config".content = ''
                  [user]
                    name = greyxp1
                    email = greyxp999@gmail.com
                  [init]
                    defaultBranch = main
                '';
              }).wrapper

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
