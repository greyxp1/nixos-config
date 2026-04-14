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
        input.keyboard = {
          xkb.layout   = "us";
          repeat-delay  = 250;
          repeat-rate   = 50;
          numlock       = true;
        };

        binds = {
          "Mod+Return"  = { spawn-sh = "ghostty"; };
          "Mod+B"       = { spawn-sh = "helium"; };
          "Mod+Z"       = { spawn-sh = "zeditor"; };

          "Mod+P"       = noctalia "sessionMenu toggle";
          #"Mod"         = noctalia "controlPanel toggle";
          #"Mod+S"       = noctalia "launcher toggle";

          "Mod+Q"       = { close-window = _: {}; };
          "Mod+F"       = { maximize-column = _: {}; };
          "Mod+Shift+F" = { fullscreen-window = _: {}; };
          "Mod+T"       = { toggle-window-floating = _: {}; };
          "Mod+C"       = { center-column = _: {}; };

          "Mod+H"       = { focus-column-left = _: {}; };
          "Mod+L"       = { focus-column-right = _: {}; };
          "Mod+J"       = { focus-window-down = _: {}; };
          "Mod+K"       = { focus-window-up = _: {}; };
          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";
          "Mod+Shift+L" = noctalia "lockScreen lock";
          "Mod+Shift+E" = { quit = _: { props.skip-confirmation = true; }; };
        };

        layout = {
          gaps = 8;
          border = {
            width          = 2;
            active-color   = "#cba6f7";
            inactive-color = "#313244";
          };
          focus-ring.off = _: {};
        };

        window-rules = [
          {
            geometry-corner-radius = 20;
            clip-to-geometry = true;
          }
        ];

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
