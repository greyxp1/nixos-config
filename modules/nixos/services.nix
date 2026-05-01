{ ... }: {
  flake.nixosModules.services = { ... }: {
    services = {
      greetd = {
        enable = true;
        useTextGreeter = true;
        restart = false;
        settings.default_session = {
          command = "niri-session";
          user = "grey";
        };
      };

      flatpak.enable = true;
      upower.enable = true;
      power-profiles-daemon.enable = true;
      #gnome.gnome-keyring.enable = true;
      dbus.enable = true;
    };

    #security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
