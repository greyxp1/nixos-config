{ pkgs, lib, ... }: {
  # Lanzaboote replaces systemd-boot for Secure Boot support.
  # Keys are generated once on first activation and stored in /var/lib/sbctl.
  boot.loader.systemd-boot.enable      = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable    = true;
    pkiBundle = "/var/lib/sbctl";
  };

  system.activationScripts.sbctl-keys = {
    text = ''
      if [ ! -d /var/lib/sbctl ]; then
        ${pkgs.sbctl}/bin/sbctl create-keys
      fi
    '';
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
