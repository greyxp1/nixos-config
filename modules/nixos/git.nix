{ inputs, ... }:
{
  imports = [
    (inputs.wrappers.lib.mkInstallModule {
      name  = "git";
      value = inputs.wrappers.lib.wrapperModules.git;
    })
  ];

  wrappers.git = {
    enable = true;
    settings = {
      user = {
        name  = "greyxp1";
        email = "greyxp999@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase         = true;
    };
  };
}
