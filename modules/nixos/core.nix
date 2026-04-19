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
