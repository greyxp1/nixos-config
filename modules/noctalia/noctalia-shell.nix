{ ... }: {
  flake.nixosModules.noctalia-shell = { inputs, pkgs, ... }: {
    imports = [
      (inputs.wrappers.lib.mkInstallModule {
        name  = "noctalia-shell";
        value = inputs.wrappers.lib.wrapperModules.noctalia-shell;
      })
    ];

    wrappers.noctalia-shell = {
      enable = true;
      settings = (builtins.fromJSON (builtins.readFile ./noctalia.json));
      colors   = (builtins.fromJSON (builtins.readFile ./colors.json));
      plugins  = (builtins.fromJSON (builtins.readFile ./plugins.json));
    };
  };
}
