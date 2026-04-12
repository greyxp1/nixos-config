{ ... }: {
  flake.nixosModules.ghostty = { inputs, pkgs, ... }: {
    environment.systemPackages = [
      (inputs.ghosttyWrappers.wrappers.ghostty.wrap {
        inherit pkgs;
        settings = {
          background           = "1e1e2e";
          foreground           = "cdd6f4";
          cursor-color         = "f5e0dc";
          selection-background = "585b70";
          selection-foreground = "cdd6f4";
          font-family          = "JetBrainsMono Nerd Font";
          window-decoration    = false;
          cursor-style         = "block";
        };
      })
    ];
  };
}
