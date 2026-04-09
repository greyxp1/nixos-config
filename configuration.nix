{ config, pkgs, inputs, ... }: {

  time.timeZone = "America/Montreal";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;

  boot.loader = if (builtins.pathExists /sys/class/efivars) then {
      # UEFI: rEFInd
      refind.enable = true;
      efi.canTouchEfiVariables = true;
    } else {
      # BIOS: GRUB
      grub = {
        enable = true;
        # Use "nodev" for UEFI-compatible GRUB,
        # but for BIOS fallback, we use a shell trick to find the disk
        device = "/dev/disk/by-label/nixos";
        efiSupport = false;
      };
    };

    # Tell NixOS where the EFI partition is without a hardcoded path
    boot.loader.efi.efiSysMountPoint = "/boot";

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
