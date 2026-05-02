{ inputs, ... }:
{
  flake.nixosModules.packages =
    { pkgs, ... }:
    {
      home-manager.users.grey =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            # CLI tools
            neovim
            curl
            lstr
            bat
            fastfetch
            btop
            zip
            unzip
            wget
            codex
            alsa-utils

            # Nix tools
            nil
            nixd

            # Theming
            adwaita-icon-theme
            hicolor-icon-theme

            # Virtualisation
            virt-manager
            virt-viewer
            spice
            spice-gtk
            spice-protocol
            virtio-win
            win-spice

            # Other
            inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
            gpu-screen-recorder
            obsidian
            mpv
            thunar
          ];
        };

      programs = {
        dconf.enable = true;
        nix-ld.enable = true;
        nix-ld.libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          fuse3
          icu
          nss
          openssl
          curl
          expat
        ];

        nh = {
          enable = true;
          flake = "/home/grey/nixconf";

          clean = {
            enable = true;
            extraArgs = "--keep-since 7d --keep 10";
          };
        };
      };
    };
}
