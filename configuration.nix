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

  # Auto-login grey on tty1 so niri can start without a display manager.
  services.getty.autologinUser = "grey";

  # Start niri-session automatically when grey's systemd user session starts.
  # This fires after autologin and is the clean, reliable way to launch a
  # Wayland compositor on NixOS without a display manager.
  systemd.user.services.niri-session = {
    description = "Niri Wayland compositor session";
    # Start after the basic user session target, but only on tty1
    wantedBy = [ "default.target" ];
    # Don't start if a graphical session is already running
    conflicts = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.niri}/bin/niri-session";
      # Restart on failure but not if it exits cleanly (e.g. Mod+Shift+E)
      Restart = "on-failure";
      RestartSec = "3s";
      # niri-session needs these env vars for proper Wayland operation
      Environment = [
        "XDG_SESSION_TYPE=wayland"
        "XDG_CURRENT_DESKTOP=niri"
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
