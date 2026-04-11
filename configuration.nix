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

  systemd.tmpfiles.rules = [
    "d /etc/nixos 0755 grey users -"
  ];

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding          = true;
      PermitRootLogin        = "yes";
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  services.greetd = {
    enable         = true;
    useTextGreeter = true;
    restart        = false;
    settings.initial_session = {
      command = "niri-session";
      user    = "grey";
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
