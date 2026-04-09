{ inputs, ... }: {
  imports = [
    (inputs.wrappers.lib.mkInstallModule {
      name  = "niri";
      value = inputs.wrappers.lib.wrapperModules.niri;
    })
  ];

  wrappers.niri = {
    enable = true;
    v2-settings = true;

    settings = {
      input.keyboard.xkb.layout = "us";

      binds = {
        "Mod+Return"  = { spawn-sh = "ghostty"; };
        "Mod+Q"       = { close-window = _: {}; };
        "Mod+H"       = { focus-column-left = _: {}; };
        "Mod+L"       = { focus-column-right = _: {}; };
        "Mod+J"       = { focus-window-down = _: {}; };
        "Mod+K"       = { focus-window-up = _: {}; };
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
}
