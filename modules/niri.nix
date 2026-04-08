{ inputs, pkgs, ... }:
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
      # Map your keybinds
      input.keyboard.xkb.layout = "us";
      # Output configuration
      # outputs."eDP-1".scale = 2.0;
      binds = {
        "Mod+T".spawn-sh = "ghostty";
        #"Mod+D".spawn-sh = "fuzzel";
        "Mod+Q"          = { close-window = { }; };
        "Mod+Shift+E"    = { quit = { skip-confirmation = [ ]; }; };
        "Mod+H"          = { focus-column-left = null; };
        "Mod+L"          = { focus-column-right = null; };
        "Mod+J"          = { focus-window-down = null; };
        "Mod+K"          = { focus-window-up = null; };
      };

      layout = {
        gaps = 8;
        border = {
          width = 2;
          active-color = "#cba6f7";
          inactive-color = "#313244";
        };
        focus-ring.off = { };
      };
    };



    #startupPrograms = [
    #  [ "waybar" ]
    #  [ "swaybg" "-i" "/path/to/wallpaper.png" ]
    #];
  };
}
