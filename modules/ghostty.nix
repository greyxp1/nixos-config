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

{ inputs, ... }:
{
  imports = [
    (inputs.wrappers.lib.mkInstallModule {
      name  = "ghostty";
      value = inputs.wrappers.lib.wrapperModules.ghostty;
    })
  ];

  wrappers.ghostty = {
    enable = true;
    settings = {
      user = {
        name  = "greyxp1";
        email = "greyxp999@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}
