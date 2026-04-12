{ inputs, ... }:
let
  # Extension IDs from the Chrome Web Store
  extensions = [
    "mnjggcdmjocbbbhaepdhchncahnbgone" # Helium Vertical Tab Bar
    "ldgfbffkinooeloadekpmfoklnobpien" # Raindrop.io
    "ghmbeldphafepmbegfdlkpapadhbakde" # Proton Pass
    "lodcanccmfbpjjpnngindkkmiehimile" # Control Panel for YouTube
  ];

  # Force-install policy JSON — Helium reads this on startup and installs
  # any listed extensions that aren't already present.
  policyJson = builtins.toJSON {
    ExtensionInstallForcelist = map
      (id: "${id};https://clients2.google.com/service/update2/crx")
      extensions;
  };
in {
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

  flake.nixosModules.helium = { pkgs, flakePackages, ... }: {
    # Write the extension force-install policy to the system policy directory.
    # Helium checks /etc/net.imput.helium/policies/managed/ on startup.
    environment.etc."net.imput.helium/policies/managed/extensions.json" = {
      text   = policyJson;
      mode   = "0644";
    };

    environment.systemPackages = [ flakePackages.helium ];

    # Home Manager configuration for the grey user.
    # Seeds Local State (flags) and Default/Preferences (settings) on first
    # launch only — Helium owns these files after that and we don't overwrite.
    home-manager.users.grey = { config, lib, ... }: {
      home.stateVersion = "23.11";

      # Activation script seeds config files only if they don't exist yet,
      # so Helium can continue to manage them after first launch.
      home.activation.heliumConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        HELIUM_DIR="$HOME/.config/net.imput.helium"
        mkdir -p "$HELIUM_DIR/Default"

        # Seed Local State with flags if it doesn't exist yet
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

        # Seed Default/Preferences with settings if it doesn't exist yet
        PREFS="$HELIUM_DIR/Default/Preferences"
        if [ ! -f "$PREFS" ]; then
          cat > "$PREFS" << 'JSONEOF'
{
  "browser": {
    "has_seen_welcome_page": true
  },
  "default_search_provider": {
    "enabled": true
  },
  "default_search_provider_data": {
    "template_url_data": {
      "keyword": "google.com",
      "short_name": "Google",
      "url": "{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:iOSSearchLanguage}{google:searchClient}{google:sourceId}&ie={inputEncoding}"
    }
  },
  "helium": {
    "zen_mode": true,
    "browser_layout": "vertical"
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
