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

      xserver.videoDrivers = [ "nvidia" ];

#      gnome = {
#        gnome-keyring.enable = false;
#        gnome-settings-daemon.enable = true;
#      };

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

#    # 1. Add icon themes to system packages
#    environment.systemPackages = with pkgs; [
#      adwaita-icon-theme
#      hicolor-icon-theme
#    ];
#
#    # 2. Enable dconf for GTK/Icon settings management
#    programs.dconf.enable = true;

    security.polkit.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = [ "gtk" ];
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "23.11";
  };
}
