{ ... }: {
  flake.nixosModules.noctalia-shell = { inputs, pkgs, ... }: {
    imports = [
      (inputs.wrapper-modules.lib.mkInstallModule {
        name  = "noctalia-shell";
        value = inputs.wrapper-modules.lib.wrapperModules.noctalia-shell;
      })
    ];

    wrappers.noctalia-shell = {
      enable = true;

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
          settings  = (builtins.fromJSON (builtins.readFile ./screen-recorder.json));
        };
      };
    };
  };
}
