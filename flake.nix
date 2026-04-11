{
  description = "Modular Wrapper Flake";

  inputs = {
    nixpkgs.url            = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghosttyWrappers = {
      url = "github:nouritsu/nix-wrapper-modules/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
    systems = [ "x86_64-linux" ];

    # ── Per-system packages ────────────────────────────────────────────────────
    # Wrapping logic lives here so packages can be tested independently with
    # `nix build .#helium` or `nix build .#zed` without a full system rebuild.
    perSystem = { pkgs, inputs', ... }: {
      packages = {
        helium = pkgs.symlinkJoin {
          name = "helium";
          paths = [ inputs'.helium.packages.default ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/helium \
              --add-flags '--ozone-platform=wayland' \
              --add-flags '--enable-features=WaylandWindowDecorations' \
              --add-flags '--disable-features=UseChromeOSDirectVideoDecoder'
          '';
        };

        zed = pkgs.symlinkJoin {
          name = "zed-editor";
          paths = [ pkgs.zed-editor ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/zeditor \
              --set WAYLAND_DISPLAY "$WAYLAND_DISPLAY" \
              --set XDG_SESSION_TYPE "wayland"
          '';
        };
      };
    };

    # ── NixOS configuration ────────────────────────────────────────────────────
    # withSystem gives access to perSystem.packages so the wrapped apps can be
    # passed into the NixOS module tree via specialArgs.flakePackages.
    flake.nixosConfigurations.greyxp1 = withSystem "x86_64-linux" ({ config, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          self          = inputs.self;
          flakePackages = config.packages;
        };
        modules = [
          inputs.lanzaboote.nixosModules.lanzaboote
          (if builtins.pathExists ./bootloader.nix then ./bootloader.nix else {})
          ./hardware-configuration.nix
          ./configuration.nix
          ./modules/nixpkgs.nix
          ./modules/git.nix
          ./modules/niri.nix
          ./modules/ghostty.nix
          ./modules/noctalia-shell.nix
          ./modules/helium.nix
          ./modules/zed.nix
        ];
      }
    );
  });
}
