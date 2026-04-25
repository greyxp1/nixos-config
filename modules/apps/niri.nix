{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable  = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
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
        };

        outputs = {
          "Acer Technologies XV320QU LV 13110DBDC4200" = {
            mode = "2560x1440@170.071";
          };
        };

        cursor = {
          xcursor-theme = "catppuccin-mocha-mauve-cursors";
          xcursor-size  = 24;
        };

        gestures.hot-corners.off = _: {};

        workspaces = {
          "1" = _: {};
          "2" = _: {};
          "3" = _: {};
        };

        binds = {
          "Mod+Return".spawn-sh = "ghostty";
          "Mod+B".spawn-sh = "helium";
          "Mod+D".spawn-sh = "equibop";
          "Mod+Z".spawn-sh = "zeditor";

          "Mod+P"     = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "sessionMenu" "toggle" ]; };
          "Mod+C"     = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "controlCenter" "toggle" ]; };
          "Mod+Space" = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "launcher" "toggle" ]; };
          "Mod+O"     = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "bar" "toggle" ]; };

          XF86AudioRaiseVolume = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "volume" "increase" ]; };
          XF86AudioLowerVolume = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "volume" "decrease" ]; };
          XF86AudioMute        = { spawn = [ (lib.getExe self'.packages.noctalia) "ipc" "call" "volume" "muteOutput" ]; };

          "Mod+Q"       = { close-window          = _: {}; };
          "Mod+F"       = { maximize-column        = _: {}; };
          "Mod+Shift+F" = { fullscreen-window       = _: {}; };
          "Mod+T"       = { toggle-window-floating  = _: {}; };
          "Mod+Tab"     = { toggle-overview          = _: {}; };
          "Print"       = { screenshot               = _: {}; };

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
          };
          background-color = "transparent";
        };

        window-rules = [
          {
            geometry-corner-radius      = 10;
            clip-to-geometry            = true;
            draw-border-with-background = false;
          }
          {
            matches = [
              { app-id = "(?i)helium"; }
              { app-id = "(?i)zed"; }
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
          {
            background-effect = {
              blur = true;
              xray = false;
            };
          }
        ];

        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper*"; } ];
            place-within-backdrop = true;
          }
        ];

        hotkey-overlay = [
          {
            skip-at-startup = true;
            hide-not-bound  = true;
          }
        ];

        overview.workspace-shadow.off = _: {};
        prefer-no-csd = true;
        debug.honor-xdg-activation-with-invalid-serial = true;

        spawn-at-startup = [
          [ "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=niri" ]
          [ "sh" "-c" "while ! busctl --user status org.gnome.Mutter.ScreenCast >/dev/null 2>&1; do sleep 0.2; done; pkill -f xdg-desktop-portal-gnome" ]
          (lib.getExe self'.packages.noctalia)
          [ "equibop" ]
          [ "niri" "msg" "action" "focus-workspace" "2" ]
        ];
      };
    };
  };
}
