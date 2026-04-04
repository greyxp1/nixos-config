{ config, pkgs, ... }: {
  imports = [
    # This points to the physical reality of the specific machine
    /etc/nixos/hardware-configuration.nix
    ./disko-config.nix
  ];

  # Bootloader setup (Systemd-boot works on 99% of modern UEFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Define your user account
  users.users.grey = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "password";
  };

  # Enable flakes by default
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Your Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];

  system.stateVersion = "23.11";
}
