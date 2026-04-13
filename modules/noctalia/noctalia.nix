{ ... }: {
  flake.nixosModules.noctalia = { inputs, pkgs, ... }: {
    imports = [
      (inputs.wrappers.lib.mkInstallModule {
        name  = "noctalia";
        value = inputs.wrappers.lib.wrapperModules.noctalia;
      })
    ];

    wrappers.noctalia = {
      enable = true;
      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
