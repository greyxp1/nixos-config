{ ... }: {
  # Wayland desktop stack shared by all hosts.
  # Nvidia-specific options live in hosts/main-pc/host.nix.
  flake.nixosModules.desktop = { pkgs, ... }: {
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
    };

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };

    # Basic graphics acceleration — Nvidia driver added per-host.
    hardware.graphics = {
      enable      = true;
      enable32Bit = true;
    };
  };
}
