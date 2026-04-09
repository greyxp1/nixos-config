{ inputs, ... }:
{
  imports = [
    (inputs.wrappers.lib.mkInstallModule {
      name  = "noctalia-shell";
      value = inputs.wrappers.lib.wrapperModules.noctalia-shell;
    })
  ];

  wrappers.noctalia-shell = {
    enable = true;
    settings = {
    };
  };
}
