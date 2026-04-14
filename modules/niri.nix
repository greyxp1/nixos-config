{ ... }: {
  flake.nixosModules.niri = { inputs, pkgs, lib, ... }:
  let
    noctalia = cmd: {
      spawn = [ "noctalia-shell" "ipc" "call" ] ++ lib.splitString " " cmd;
    };

    wrappedNiri = inputs.wrappers.wrappers.niri.wrap {
      inherit pkgs;
      v2-settings = true;
      settings = {
        input = {
          keyboard = {
            xkb = {
              layout = "us";
              options = "caps:escape";
            };
            repeat-delay = 250;
            repeat-rate = 50;
            numlock = true;
          };
          touchpad = { };
        };

        binds = {
          "Mod+Return"  = { spawn-sh = "ghostty"; };
          "Mod+B"       = { spawn-sh = "helium"; };
          "Mod+Z"       = { spawn-sh = "zeditor"; };
          "Mod+D"       = { spawn-sh = "equibop"; };

          "Mod+P"       = noctalia "sessionMenu toggle";
          "Mod+C"       = noctalia "controlCenter toggle";
          "Mod+Space"   = noctalia "launcher toggle";

          "Mod+Q"       = { close-window = _: {}; };
          "Mod+F"       = { maximize-column = _: {}; };
          "Mod+Shift+F" = { fullscreen-window = _: {}; };
          "Mod+T"       = { toggle-window-floating = _: {}; };
          "Mod+Tab"     = { toggle-overview = _: {}; };
          "Print"       = { screenshot = _: {}; };
          #"Mod+C"       = { center-column = _: {}; };
          #"Mod+Shift+E" = { quit = _: { props.skip-confirmation = true; }; };

          "Mod+H"       = { focus-column-left = _: {}; };
          "Mod+L"       = { focus-column-right = _: {}; };
          "Mod+J"       = { focus-window-down = _: {}; };
          "Mod+K"       = { focus-window-up = _: {}; };
          "Mod+Ctrl+H"  = { set-column-width = "-5%"; };
          "Mod+Ctrl+L"  = { set-column-width = "+5%"; };
          "Mod+Ctrl+J"  = { set-window-height = "-5%"; };
          "Mod+Ctrl+K"  = { set-window-height = "+5%"; };
        };

        layout = {
          gaps = 10;
          border = {
            width          = 2;
            active-color   = "#89b4fa";
            inactive-color = "#232634";
          };
          focus-ring.off = _: {};
          background-color = "transparent";
        };

        window-rules = [
          {
            geometry-corner-radius = 20;
            clip-to-geometry = true;
            draw-border-with-background = false;
          }
        ];

        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper*"; } ];
            place-within-backdrop = true;
          }
        ];

        overview.workspace-shadow.off = _: {};
        prefer-no-csd = true;

        debug = { honor-xdg-activation-with-invalid-serial = true; };

        spawn-at-startup = [ "noctalia-shell" ];
      };
    };
  in {
    programs.niri = {
      enable  = true;
      package = wrappedNiri;
    };
  };
}
