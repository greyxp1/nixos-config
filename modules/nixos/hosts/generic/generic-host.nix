{ pkgs, ... }: {
  networking.hostName = "generic";

  # Standard latest kernel — no vendor overlay needed.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
