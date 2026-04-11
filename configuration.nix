{ config, pkgs, inputs, lib, ... }: {

  time.timeZone          = "America/Montreal";
  networking.hostName    = "nixos";
  networking.networkmanager.enable       = true;
  hardware.enableRedistributableFirmware = true;

  swapDevices = [ { device = "/var/lib/swapfile"; size = 4096; } ];

  users.users.grey = {
    isNormalUser    = true;
    extraGroups     = [ "networkmanager" "wheel" "video" "input" ];
    initialPassword = "123";
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding          = true;
      PermitRootLogin        = "yes";
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  # programs.niri.enable is set in modules/niri.nix alongside the package.
  services.greetd = {
    enable         = true;
    useTextGreeter = true;
    restart        = false;
    settings = {
      initial_session = {
        command = "niri-session";
        user    = "grey";
      };
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --cmd niri-session";
        user    = "greeter";
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
}
