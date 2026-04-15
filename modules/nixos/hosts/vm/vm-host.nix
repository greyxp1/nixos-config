{ pkgs, ... }: {
  networking.hostName = "vm";

  # Standard kernel — no CachyOS overlay needed.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # QEMU/SPICE guest integration (clipboard, auto-resize, etc.)
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable      = true;

  environment.systemPackages = with pkgs; [ spice-vdagent ];
}
