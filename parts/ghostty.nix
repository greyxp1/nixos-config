{ inputs, ... }: {
  perSystem = { pkgs, system, ... }: {
    packages.ghostty-custom = inputs.wrappers.packages.${system}.ghostty.wrap {
      inherit pkgs;
      settings = {
        theme = "dark";
        font-family = "JetBrainsMono Nerd Font";
        window-decoration = false;
        cursor-style = "block";
      };
    };
  };
}
