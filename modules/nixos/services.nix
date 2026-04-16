{ ... }: {
  flake.nixosModules.services = { pkgs, ... }: {
    services = {
      upower.enable = true;

#      greetd = {
#        enable         = true;
#        useTextGreeter = true;
#        restart        = false;
#        settings.default_session = {
#          command = "niri-session";
#          user    = "grey";
#        };
#      };

      openssh = {
        enable   = true;
        settings = {
          X11Forwarding          = true;
          PermitRootLogin        = "yes";
          PasswordAuthentication = true;
        };
        openFirewall = true;
      };
    };

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };

    hardware.graphics = {
      enable      = true;
      enable32Bit = true;
    };
  };
}
