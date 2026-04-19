{ ... }: {
  flake.nixosModules.ghostty = { inputs, pkgs, ... }: {
    environment.systemPackages = [
      (inputs.ghosttyWrappers.wrappers.ghostty.wrap {
        inherit pkgs;
        settings = {
          theme = "Catppuccin Mocha";
          background-opacity = 0.81;
        };
      })
    ];
  };
}
