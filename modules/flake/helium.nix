{ inputs, ... }: {
  perSystem = { pkgs, inputs', ... }: {
    packages.helium = pkgs.symlinkJoin {
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
  };

  flake.nixosModules.helium = { flakePackages, ... }: {
    environment.systemPackages = [ flakePackages.helium ];

    home-manager.users.grey = { lib, ... }: {
      home.stateVersion = "23.11";

      home.activation.heliumConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        HELIUM_DIR="$HOME/.config/net.imput.helium"
        mkdir -p "$HELIUM_DIR/Default"

        # Seed Local State (flags) only on first launch
        LOCAL_STATE="$HELIUM_DIR/Local State"
        if [ ! -f "$LOCAL_STATE" ]; then
          cat > "$LOCAL_STATE" << 'JSONEOF'
{
  "browser": {
    "enabled_labs_experiments": [
      "helium-zen-mode@1",
      "smooth-scrolling@1",
      "enable-gpu-rasterization@1",
      "enable-zero-copy@1",
      "enable-parallel-downloading@1"
    ]
  }
}
JSONEOF
        fi

        # Seed Default/Preferences only on first launch
        PREFS="$HELIUM_DIR/Default/Preferences"
        if [ ! -f "$PREFS" ]; then
          cat > "$PREFS" << 'JSONEOF'
{
  "browser": {
    "has_seen_welcome_page": true
  },
  "ntp": {
    "tab_hover_card_images": false
  }
}
JSONEOF
        fi
      '';
    };
  };
}
