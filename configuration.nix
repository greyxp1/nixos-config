{ config, pkgs, inputs, ... }: {

  time.timeZone = "America/Montreal";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 4096;
  } ];

  users.users.grey = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
    initialPassword = "123";
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  programs.niri.enable = true;

  services.getty.autologinUser = "grey";

  environment.etc."profile.d/start-niri.sh".text = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec niri-session
    fi
  '';

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
