{ ... }: {
  flake.nixosModules.core = { config, ... }: {
    time.timeZone                          = "America/Montreal";
    networking.networkmanager.enable       = true;
    hardware.enableRedistributableFirmware = true;

    # Persistent swap file (4 GiB).  The installer's temporary swapfile is
    # removed on first boot; this one is the permanent replacement.
    swapDevices = [ { device = "/var/lib/swapfile"; size = 4096; } ];

    users.users.grey = {
      isNormalUser    = true;
      extraGroups     = [ "networkmanager" "wheel" "video" "input" ];
      initialPassword = "123";
    };

    # Allow the config owner to edit /etc/nixos without sudo.
    systemd.tmpfiles.rules = [
      "Z /etc/nixos - grey users - -"
    ];

    system.nixos.label     = config.networking.hostName;
    security.polkit.enable = true;
    system.stateVersion    = "23.11";
  };
}
