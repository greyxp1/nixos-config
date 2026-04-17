{ ... }: {
  flake.nixosModules.git = { inputs, ... }: {
    imports = [
      (inputs.wrapper-modules.lib.mkInstallModule {
        name  = "git";
        value = inputs.wrapper-modules.lib.wrapperModules.git;
      })
    ];

    wrappers.git = {
      enable   = true;
      settings = {
        user = {
          name  = "greyxp1";
          email = "greyxp999@gmail.com";
        };
        init.defaultBranch = "main";
        pull.rebase        = true;
      };
    };
  };
}
