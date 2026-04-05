{ config, pkgs, ... }: {
  imports = [
    ./disko-config.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Montreal";

  users.users.grey = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "password";
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.niri.enable = true;
  services.displayManager.defaultSession = "niri";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];

  system.stateVersion = "23.11";
}
