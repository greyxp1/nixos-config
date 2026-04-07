{ config, pkgs, inputs, ... }: {
  imports = [
    ./disko-config.nix
  ];

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
    extraGroups = [ "networkmanager" "wheel" ];
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
  programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
  services.displayManager.ly.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    tree
    bat
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
