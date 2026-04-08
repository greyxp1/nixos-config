{ inputs, ... }:
{
  imports = [
    (inputs.wrappers.lib.mkInstallModule {
      name  = "niri";
      value = inputs.wrappers.lib.wrapperModules.niri;
    })
  ];

  wrappers.niri = {
    enable = true;

    settings = {
      input.keyboard.xkb.layout = "us";
      # outputs."eDP-1".scale = 2.0;

      binds = {
        "Mod+T"       = { spawn-sh = "ghostty"; };
        #"Mod+D"      = { spawn-sh = "fuzzel"; };
        "Mod+Q"       = { close-window = null; };
        # quit takes `skip-confirmation` as a KDL *property* (an argument on
        # the node itself), not a child node. Use the `_:` function form so
        # wlib.toKdl renders:  quit skip-confirmation=true
        # instead of:          quit { skip-confirmation true }
        "Mod+Shift+E" = { quit = _: { props.skip-confirmation = true; }; };
        "Mod+H"       = { focus-column-left = null; };
        "Mod+L"       = { focus-column-right = null; };
        "Mod+J"       = { focus-window-down = null; };
        "Mod+K"       = { focus-window-up = null; };
      };

      layout = {
        gaps = 8;
        border = {
          width          = 2;
          active-color   = "#cba6f7";
          inactive-color = "#313244";
        };
        focus-ring.off = null;
      };

      # spawn-at-startup = [
      #   "waybar"
      #   [ "swaybg" "-i" "/path/to/wallpaper.png" ]
      # ];
    };
  };
}
