{ ... }: {
  flake.nixosModules.configuration = { config, pkgs, lib, ... }: {
    time.timeZone                        = "America/Montreal";
    networking.hostName                  = "greyxp1";
    networking.networkmanager.enable     = true;
    hardware.enableRedistributableFirmware = true;

    swapDevices = [ { device = "/var/lib/swapfile"; size = 4096; } ];

    users.users.grey = {
      isNormalUser    = true;
      extraGroups     = [ "networkmanager" "wheel" "video" "input" ];
      initialPassword = "123";
    };

    systemd.tmpfiles.rules = [
      "Z /etc/nixos - grey users - -"
    ];

    system.nixos.label = config.networking.hostName;

    services = {
      openssh = {
        enable = true;
        settings = {
          X11Forwarding          = true;
          PermitRootLogin        = "yes";
          PasswordAuthentication = true;
        };
        openFirewall = true;
      };

      upower.enable = true;

      gnome.gnome-keyring.enable = false;

      greetd = {
        enable         = true;
        useTextGreeter = true;
        restart        = false;
        settings.default_session = {
          command = "niri-session";
          user    = "grey";
        };
      };
    };

    security.polkit.enable = true;

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      config.common.default = "*";
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "23.11";
  };
}
