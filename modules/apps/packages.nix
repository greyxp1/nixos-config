{ inputs, ... }: {
  flake.nixosModules.packages = { pkgs, ... }: {
    home-manager.users.grey = { pkgs, ... }: {
      home.packages = with pkgs; [
        # ── CLI tools ──────────────────────────────────────────────────────────
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

        # ── Theming ────────────────────────────────────────────────────────────
        adwaita-icon-theme
        hicolor-icon-theme
        dconf

        # ── Virtualisation ─────────────────────────────────────────────────────
        virt-manager
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        virtio-win
        win-spice

        # ── Other ──────────────────────────────────────────────────────────────
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
        gpu-screen-recorder
        obsidian
        mpv
        thunar
      ];
    };
  };
}
