{ ... }: {
  flake.nixosModules.ghostty = { inputs, pkgs, ... }: {
    environment.systemPackages = [
      (inputs.ghosttyWrappers.wrappers.ghostty.wrap {
        inherit pkgs;
        settings = {

          theme = "Ghostty Default Style Dark";
          background-opacity = 0.5;
          window-decoration = false;

          clipboard-read = "allow";
          mouse-hide-while-typing = true;

          selection-background = "ffffff";
          selection-foreground = "282c34";

          cursor-color = "ffffff";
          cursor-text = "353a44";
          cursor-style = "block";

          font-family = "JetBrainsMono Nerd Font";

          palette = [
            "1=#cc6566"
            "2=#b6bd68"
            "4=#82a2be"
            "7=#c4c8c6"
            "10=#b9ca4b"
          ];
        };
      })
    ];
  };
}
