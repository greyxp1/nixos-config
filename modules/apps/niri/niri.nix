{ ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    environment.etc."xdg/niri/config.kdl".source = ./config.kdl;
  };
}
