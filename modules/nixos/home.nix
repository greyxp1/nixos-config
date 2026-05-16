{ inputs, ... }:
{
  flake.nixosModules.home =
    { ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.catppuccin.nixosModules.catppuccin
      ];

      services.flatpak.enable = true;
      programs.dconf.enable = true;

      catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "mauve";
        cache.enable = true;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        sharedModules = [ inputs.catppuccin.homeModules.catppuccin ];
        users.grey =
          { pkgs, ... }:
          {
            home = {
              username = "grey";
              homeDirectory = "/home/grey";
              stateVersion = "26.05";
              pointerCursor = {
                package = pkgs.catppuccin-cursors.mochaMauve;
                name = "catppuccin-mocha-mauve-cursors";
                size = 24;
                gtk.enable = true;
              };
              packages = with pkgs; [
                adwaita-icon-theme
                hicolor-icon-theme
                inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
            };

            catppuccin = {
              enable = true;
              flavor = "mocha";
              accent = "mauve";
            };
          };
      };
    };
}
