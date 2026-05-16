{ ... }:
{
  flake.nixosModules.equibop =
    { ... }:
    {
      home-manager.users.grey =
        { pkgs, lib, ... }:
        let
          inlineCss = pkgs.writeText "quickCss.css" ''
            @import url("https://refact0r.github.io/midnight-discord/build/midnight.css");
            @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Apple.css);
            body {
              --remove-bg-layer: on;
              --top-bar-height: var(--gap);
            }
            :root { --bg-4: hsla(220, 15%, 10%, 0.81); }
          '';
        in
        {
          home.packages = [
            (pkgs.equibop.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
              postFixup = (old.postFixup or "") + ''
                wrapProgram $out/bin/equibop \
                  --add-flags "--force_high_performance_gpu" \
                  --add-flags "--enable-features=VaapiVideoDecodeLinuxGL"
              '';
            }))
          ];

          home.activation.equibopSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            EQUIBOP_DIR="$HOME/.config/equibop"
            install -d -m 0755 "$EQUIBOP_DIR/settings"
            install -m 0644 ${inlineCss} "$EQUIBOP_DIR/settings/quickCss.css"
            install -m 0644 ${./plugins.json} "$EQUIBOP_DIR/settings/settings.json"
            install -m 0644 ${./settings.json} "$EQUIBOP_DIR/settings.json"
            printf '{"firstLaunch":false}\n' > "$EQUIBOP_DIR/state.json"
            chmod 0644 "$EQUIBOP_DIR/state.json"
          '';
        };
    };
}
