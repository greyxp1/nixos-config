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

    # 1. Enable dconf and set global overrides
        programs.dconf.enable = true;
        programs.dconf.profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                gtk-theme = "Adwaita-dark";
              };
            };
          }
        ];

        # 2. Set environment variables to force dark mode in stubborn apps
        environment.sessionVariables = {
          GTK_THEME = "Adwaita:dark";
          QT_QPA_PLATFORMTHEME = "gnome";
          # Helps Helium/Chromium detect dark mode on Wayland
          NIX_OZONE_WL = "1";
        };

        # 3. Essential packages (Removed glib, kept themes)
        environment.systemPackages = with pkgs; [
          gnome-themes-extra  # Required for Adwaita-dark assets
          adwaita-qt
          adwaita-qt6
        ];

        # 4. Portals & D-Bus signals (The "Broadcast" system)
        # This allows Zed and Helium to "see" your dconf settings
        services.dbus.packages = [ pkgs.gsettings-desktop-schemas ];

        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-gnome # Better support for the color-scheme signal
          ];
          config.common.default = [ "gtk" "gnome" ];
        };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "23.11";
  };
}
