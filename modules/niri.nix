{ inputs, pkgs, lib, ... }:
let
  noctalia = cmd: {
    spawn = [
      "noctalia-shell"
      "ipc"
      "call"
    ] ++ lib.splitString " " cmd;
  };

  wrappedNiri = inputs.wrappers.wrappers.niri.wrap {
    inherit pkgs;
    v2-settings = true;
    settings = {
      input.keyboard {
        xkb.layout = "us";
        repeat-delay = 250;
        repeat-rate  = 50;
        numlock
      }

      binds = {
        "Mod+Return"  = { spawn-sh = "ghostty"; };
        "Mod+P"       = noctalia "sessionMenu toggle";
        "Mod+Q"       = { close-window = _: {}; };
        "Mod+H"       = { focus-column-left = _: {}; };
        "Mod+L"       = { focus-column-right = _: {}; };
        "Mod+J"       = { focus-window-down = _: {}; };
        "Mod+K"       = { focus-window-up = _: {}; };
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

      spawn-at-startup = [
        "noctalia-shell"
      ];
    };
  };
in
{
  programs.niri = {
    enable  = true;
    package = wrappedNiri;
  };
}
