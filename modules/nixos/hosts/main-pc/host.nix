{ inputs, pkgs, ... }: {
  networking.hostName = "main-pc";

  # ── CachyOS kernel ───────────────────────────────────────────────────────────
  nixpkgs.overlays    = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # ── Extra binary caches for CachyOS packages ─────────────────────────────────
  nix.settings = {
    extra-substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  # ── Nvidia ───────────────────────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open               = true;
    modesetting.enable = true;
  };
}
