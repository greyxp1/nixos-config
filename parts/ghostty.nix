{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.ghostty-custom = inputs.wrappers.wrappers.ghostty.wrap {
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
