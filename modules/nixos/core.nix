{ ... }: {
  flake.nixosModules.core = { config, pkgs, ... }: {
    time.timeZone                          = "America/Montreal";
    networking.networkmanager.enable       = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true;

    swapDevices = [ { device = "/var/lib/swapfile"; size = 4096; } ];

    users.users.grey = {
      isNormalUser    = true;
      extraGroups     = [ "networkmanager" "wheel" "video" "input" ];
      initialPassword = "123";
    };

    nix.settings = {
      trusted-users         = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];

      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7SwKTPnCQST63SSTtmdclW2K89XSTmB5V9sMo=" ];
    };

    environment.variables = {
      QT_QPA_PLATFORMTHEME = "gtk3";
      XCURSOR_SIZE         = "32";
      XCURSOR_THEME        = "Adwaita";
    };

    programs.dconf.enable = true;

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };

    hardware.graphics = {
      enable      = true;
      enable32Bit = true;
    };

    system.nixos.label     = config.networking.hostName;
    security.polkit.enable = true;
    system.stateVersion    = "23.11";
  };
}
