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

  # Automatically generate Secure Boot keys on first boot if they don't exist.
  # This allows the system to boot and rebuild correctly out of the box —
  # the user can then choose to enroll the keys and enable Secure Boot in their
  # UEFI firmware settings, but it's not required for normal operation.
  system.activationScripts.sbctl-keys = lib.mkIf isUEFI {
    text = ''
      if [ ! -d /var/lib/sbctl ]; then
        ${pkgs.sbctl}/bin/sbctl create-keys
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    sbctl  # Secure Boot key management and signature verification
  ];

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
