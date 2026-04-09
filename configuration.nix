{ config, pkgs, inputs, ... }: {

  time.timeZone = "America/Montreal";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Detect if booted via UEFI or Legacy BIOS
    boot.loader = let
      isUEFI = builtins.pathExists /sys/class/efivars;
    in {
      efi.canTouchEfiVariables = isUEFI;
      efi.efiSysMountPoint = "/boot";

      # Enable rEFInd for UEFI, GRUB for BIOS
      refind.enable = isUEFI;
      grub = {
        enable = !isUEFI;
        device = "/dev/disk/by-partlabel/disk-nixos-boot";
        efiSupport = false;
      };
    };

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

  # programs.niri.enable is set in modules/niri.nix alongside the package.
  # greetd auto-logs in as grey and immediately launches niri-session,
  # which uses programs.niri.package — our wrapped niri.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd niri-session";
        user    = "grey";
      };
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
