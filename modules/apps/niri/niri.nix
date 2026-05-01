{ inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri = {
      enable  = true;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    };

    home-manager.sharedModules = [{
      programs.niri.config = builtins.readFile ./config.kdl;
      home.packages = [ inputs.nirimod.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      home.sessionVariables.NIRIMOD_CONFIG_DIR = "$HOME/nixconf/modules/apps/niri";
    }];
  };
}
