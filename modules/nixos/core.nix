{ ... }: {
  flake.nixosModules.core = { config, pkgs, ... }: {
    time.timeZone                          = "America/Montreal";
    networking.networkmanager.enable       = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree            = true;

    zramSwap = {
      enable    = true;
      algorithm = "zstd";
    };

    users.users.grey = {
      isNormalUser    = true;
      extraGroups     = [ "networkmanager" "wheel" "video" "input" ];
      initialPassword = "123";
    };

    nix.settings = {
      trusted-users         = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];

      substituters        = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7SwKTPnCQST63SSTtmdclW2K89XSTmB5V9sMo=" ];
    };

    catppuccin = {
      flavor = "mocha";
      accent = "mauve";
    };

    catppuccin.cursors = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
    };

    environment.variables.XCURSOR_SIZE = "16";

    home-manager.useGlobalPkgs   = true;
    home-manager.useUserPackages = true;

    programs.dconf.enable = true;

    xdg.portal = {
      enable        = true;
      extraPortals  = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };

    xdg.mime.defaultApplications = {
      "x-scheme-handler/http"  = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "text/html"              = "helium.desktop";
    };

    hardware.graphics = {
      enable      = true;
      enable32Bit = true;
    };

    services = {
      upower.enable = true;

      greetd = {
        enable   = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
            user    = "greeter";
          };
        };
      };

      flatpak.enable = true;
    };

    system.nixos.label     = config.networking.hostName;
    security.polkit.enable = true;
    system.stateVersion    = "25.11";
  };
}
