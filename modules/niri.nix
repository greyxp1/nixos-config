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

    # Opt into the new v2 KDL translation scheme.
    # This silences all the deprecation warnings and ensures `null` is no
    # longer used to represent empty nodes — `_: {}` is used instead.
    # The compat layer is removed on July 1, 2026.
    v2-settings = true;

    settings = {
      input.keyboard.xkb.layout = "us";
      # outputs."eDP-1".scale = 2.0;

      binds = {
        "Mod+T"       = { spawn-sh = "ghostty"; };
        #"Mod+D"      = { spawn-sh = "fuzzel"; };

        # In v2: empty-child nodes use `_: {}` instead of `null`
        "Mod+Q"       = { close-window = _: {}; };
        "Mod+H"       = { focus-column-left = _: {}; };
        "Mod+L"       = { focus-column-right = _: {}; };
        "Mod+J"       = { focus-window-down = _: {}; };
        "Mod+K"       = { focus-window-up = _: {}; };

        # Props (inline KDL arguments) still use `_: { props.key = val; }`
        "Mod+Shift+E" = { quit = _: { props.skip-confirmation = true; }; };
      };

      layout = {
        gaps = 8;
        border = {
          width          = 2;
          active-color   = "#cba6f7";
          inactive-color = "#313244";
        };
        # In v2: `off` with no children/props uses `_: {}` instead of `null`
        focus-ring.off = _: {};
      };

      # spawn-at-startup = [
      #   "waybar"
      #   [ "swaybg" "-i" "/path/to/wallpaper.png" ]
      # ];
    };
  };
}
