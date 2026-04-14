{ ... }: {
  flake.nixosModules.ghostty = { inputs, pkgs, ... }: {
    environment.systemPackages = [
      (inputs.ghosttyWrappers.wrappers.ghostty.wrap {
        inherit pkgs;
        settings = {

          theme = "Ghostty Default Style Dark";
          background-opacity = 0.75;
          window-decoration = false;

          clipboard-read = "allow";
          mouse-hide-while-typing = true;

          selection-background = "ffffff";
          selection-foreground = "282c34";

          cursor-color = "ffffff";
          cursor-text = "353a44";
          cursor-style = "block";

          font-family = "JetBrainsMono Nerd Font";
        };
      })
    ];
  };
}
