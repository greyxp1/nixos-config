{ ... }: {
  flake.nixosModules.network = { ... }: {
    services.openssh = {
      enable   = true;
      settings = {
        X11Forwarding          = true;
        PermitRootLogin        = "yes";
        PasswordAuthentication = true;
      };
      openFirewall = true;
    };
  };
}
