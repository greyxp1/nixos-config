{ ... }: {
  flake.nixosModules.noctalia-shell = { inputs, pkgs, ... }: {
    imports = [
      (inputs.wrappers.lib.mkInstallModule {
        name  = "noctalia-shell";
        value = inputs.wrappers.lib.wrapperModules.noctalia-shell;
      })
    ];

    wrappers.noctalia-shell = {
      enable          = true;
      outOfStoreConfig = "/home/grey/.config/noctalia";

      settings = (builtins.fromJSON (builtins.readFile ./noctalia.json));
      colors   = (builtins.fromJSON (builtins.readFile ./colors.json));

      plugins = {
        sources = [{
          enabled = true;
          name    = "Noctalia Plugins";
          url     = "https://github.com/noctalia-dev/noctalia-plugins";
        }];
        version = 2;
      };

      preInstalledPlugins = {
        polkit-agent = {
          enabled   = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          src       = "${inputs.noctalia-plugins}/polkit-agent";
        };
        screen-recorder = {
          enabled   = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          src       = "${inputs.noctalia-plugins}/screen-recorder";
        };
      };
    };
  };
}
