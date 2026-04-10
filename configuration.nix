{ config, pkgs, inputs, lib, ... }:
let
  # Evaluated at nixos-install time on the installer host — correctly reflects
  # the firmware type of the machine being installed onto.
  isUEFI = builtins.pathExists /sys/firmware/efi/efivars;

  # Written by install.sh — e.g. "/dev/sda" or "/dev/nvme0n1"
  selectedDevice = import ./device.nix;
in {
  time.timeZone            = "America/Montreal";
  networking.hostName      = "nixos";
  networking.networkmanager.enable         = true;
  hardware.enableRedistributableFirmware   = true;

  # ── Bootloader ──────────────────────────────────────────────────────────────
  # systemd-boot on UEFI; GRUB (MBR/BIOS mode) on legacy systems.
  boot.loader = {
    efi.canTouchEfiVariables = isUEFI;
    efi.efiSysMountPoint     = "/boot";

    systemd-boot = lib.mkIf isUEFI {
      enable = true;
    };

    grub = lib.mkIf (!isUEFI) {
      enable     = true;
      device     = selectedDevice;   # installs the MBR bootloader onto the disk
      efiSupport = false;
    };
  };

  # ── Swap ────────────────────────────────────────────────────────────────────
  # NixOS creates and activates this swapfile automatically.
  # (The /mnt/swapfile created by install.sh is temporary and lives only during
  # the install run; it is not this file.)
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size   = 4096; # MiB
  } ];

  # ── Users ───────────────────────────────────────────────────────────────────
  users.users.grey = {
    isNormalUser  = true;
    extraGroups   = [ "networkmanager" "wheel" "video" "input" ];
    initialPassword = "123";
  };

  # ── SSH ─────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding       = true;
      PermitRootLogin     = "yes";
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  # ── Display / Greeter ───────────────────────────────────────────────────────
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
    enable        = true;
    extraPortals  = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
