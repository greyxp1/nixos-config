{ ... }: {
  flake.nixosModules.services = { ... }: {
    services = {
      upower.enable = true;

      greetd = {
        enable         = true;
        useTextGreeter = true;
        restart        = false;
        settings.default_session = {
          command = "niri-session";
          user    = "grey";
        };
      };

#      openssh = {
#        enable   = true;
#        settings = {
#          X11Forwarding          = true;
#          PermitRootLogin        = "yes";
#          PasswordAuthentication = true;
#        };
#        openFirewall = true;
#      };

      flatpak.enable = true;
    };
  };
}
