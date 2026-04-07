{ inputs, ... }: {
  perSystem = { pkgs, system, ... }: {
    packages.niri-custom = inputs.wrappers.packages.${system}.niri.wrap {
      inherit pkgs;
      package = inputs.niri.packages.${system}.niri;
      settings = {
        input = {
          keyboard = {
            xkb.layout = "us";
            repeat-delay = 200;
            repeat-rate = 35;
          };
          touchpad.tap = true;
        };
        layout = {
          gaps = 10;
          default-column-width = { proportion = 0.5; };
        };
        binds = {
          "Mod+Return".action.spawn = [ "ghostty" ];
          "Mod+Q".action.close-window = [];
          "Mod+Shift+E".action.quit = [];
        };
      };
    };
  };
}
