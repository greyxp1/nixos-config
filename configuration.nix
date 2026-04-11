{ config, pkgs, inputs, lib, ... }:

let
  isUEFI = builtins.pathExists "/sys/firmware/efi/efivars";
in {
  boot.loader = lib.mkMerge [
    (lib.mkIf isUEFI {
      systemd-boot.enable      = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    })
    (lib.mkIf (!isUEFI) {
      grub.enable = true;
    })
  ];

  boot.lanzaboote = lib.mkIf isUEFI {
    enable    = true;
    pkiBundle = "/var/lib/sbctl";
  };

  system.activationScripts.sbctl-keys = lib.mkIf isUEFI {
    text = ''
      if [ ! -d /var/lib/sbctl ]; then
        ${pkgs.sbctl}/bin/sbctl create-keys
      fi
    '';
  };

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
  # greetd auto-logs in as grey and immediately launches niri-session.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd}/bin/agreety --cmd niri-session";
      user    = "grey";
    };
  };

  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
