{ ... }: {
  flake.nixosModules.home = { pkgs, ... }: {
    home-manager.users.grey = { ... }: {
      home.username     = "grey";
      home.homeDirectory = "/home/grey";
      home.stateVersion  = "25.11";
    };
  };
}
