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

    programs.dconf.enable = true;
      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "Adwaita-dark";
            };
          };
        };
      ];
    # 2. Set environment variables for apps that ignore dconf
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
      QT_QPA_PLATFORMTHEME = "gnome";
    };
    # 3. Required packages for themes to actually exist
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      adwaita-qt
      adwaita-qt6
    ];
    # 4. Ensure Portals are running to broadcast the setting
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "23.11";
  };
}
