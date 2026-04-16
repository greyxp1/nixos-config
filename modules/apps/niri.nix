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
              layout  = "us";
              options = "caps:escape";
            };
            repeat-delay = 250;
            repeat-rate  = 50;
            numlock      = true;
          };
          touchpad.natural-scroll = _: {};
          #mouse = {
          #  scroll-method = "on-button-down";
          #  scroll-button = 274;
          #};
        };

        gestures.hot-corners.off = _: {};

        workspaces = {
          "1" = _: {};
          "2" = _: {};
          "3" = _: {};
        };

        binds = {
          "Mod+Return"  = { spawn-sh = "ghostty"; };
          "Mod+B"       = { spawn-sh = "helium"; };
          "Mod+Z"       = { spawn-sh = "zeditor"; };
          "Mod+D"       = { spawn-sh = "equibop"; };

          "Mod+P"     = noctalia "sessionMenu toggle";
          "Mod+C"     = noctalia "controlCenter toggle";
          "Mod+Space" = noctalia "launcher toggle";

          "Mod+Q"       = { close-window          = _: {}; };
          "Mod+F"       = { maximize-column        = _: {}; };
          "Mod+Shift+F" = { fullscreen-window       = _: {}; };
          "Mod+T"       = { toggle-window-floating  = _: {}; };
          "Mod+Tab"     = { toggle-overview          = _: {}; };
          "Print"       = { screenshot               = _: {}; };
          "Mod+Shift+E" = { quit = _: { props.skip-confirmation = true; }; };

          # Focus movement
          "Mod+H" = { focus-column-left  = _: {}; };
          "Mod+L" = { focus-column-right = _: {}; };
          "Mod+J" = { focus-window-down  = _: {}; };
          "Mod+K" = { focus-window-up    = _: {}; };

          # Window movement
          "Mod+Shift+H" = { move-column-left  = _: {}; };
          "Mod+Shift+L" = { move-column-right = _: {}; };
          "Mod+Shift+J" = { move-window-down  = _: {}; };
          "Mod+Shift+K" = { move-window-up    = _: {}; };

          # Resizing
          "Mod+Ctrl+H" = { set-column-width  = "-5%"; };
          "Mod+Ctrl+L" = { set-column-width  = "+5%"; };
          "Mod+Ctrl+J" = { set-window-height = "-5%"; };
          "Mod+Ctrl+K" = { set-window-height = "+5%"; };

          # Workspace navigation
          "Mod+Alt+J" = { focus-workspace-down = _: {}; };
          "Mod+Alt+K" = { focus-workspace-up   = _: {}; };

          # Move column across workspaces
          "Mod+Alt+Shift+J" = { move-column-to-workspace-down = _: {}; };
          "Mod+Alt+Shift+K" = { move-column-to-workspace-up   = _: {}; };

          # Scroll to navigate
          "Mod+WheelScrollUp"   = { focus-workspace-up   = _: {}; };
          "Mod+WheelScrollDown" = { focus-workspace-down = _: {}; };

          "Mod+Shift+WheelScrollUp"   = { focus-column-left  = _: {}; };
          "Mod+Shift+WheelScrollDown" = { focus-column-right = _: {}; };
        };

        layout = {
          gaps = 10;
          focus-ring = {
            width          = 3;
            active-color   = "#89b4fa";
            inactive-color = "#232634";
          };
          background-color = "transparent";
        };

        window-rules = [
          {
            geometry-corner-radius      = 20;
            clip-to-geometry            = true;
            draw-border-with-background = false;
          }
          {
            matches = [
              { app-id = "(?i)helium";   }
              { app-id = "(?i)zed";      }
              { app-id = "(?i)electron"; }
            ];
            open-maximized = true;
          }
          {
            matches           = [ { app-id = "(?i)helium"; } ];
            open-on-workspace = "1";
          }
          {
            matches           = [ { app-id = "(?i)electron"; } ];
            open-on-workspace = "3";
          }
        ];

        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-overview*"; } ];
            place-within-backdrop = true;
          }
        ];

        overview.workspace-shadow.off = _: {};
        prefer-no-csd = true;

        debug.honor-xdg-activation-with-invalid-serial = true;

        spawn-at-startup = [
          [ "noctalia-shell" ]
          [ "niri" "msg" "action" "focus-workspace" "2" ]
        ];
      };
    };
  in {
    programs.niri = {
      enable  = true;
      package = wrappedNiri;
    };
  };
}
