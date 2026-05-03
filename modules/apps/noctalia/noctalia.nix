{ inputs, ... }:
{
  flake.nixosModules.noctalia =
    { ... }:
    {
      home-manager.users.grey =
        { lib, ... }:
        {
          imports = [ inputs.noctalia.homeModules.default ];

          programs.noctalia-shell = {
            enable = true;
            settings = lib.mkForce (builtins.fromJSON (builtins.readFile ./noctalia.json));

            plugins = {
              sources = [
                {
                  enabled = true;
                  name = "Noctalia Plugins";
                  url = "https://github.com/noctalia-dev/noctalia-plugins";
                }
              ];
              states = {
                screen-recorder = {
                  enabled = true;
                  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                };
                polkit-agent = {
                  enabled = true;
                  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                };
              };
              version = 2;
            };

            pluginSettings.screen-recorder = builtins.fromJSON (builtins.readFile ./screen-recorder.json);
          };
        };
    };
}
