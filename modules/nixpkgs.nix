{ ... }: {
  flake.nixosModules.nixpkgs = { inputs, pkgs, ... }: {
    nixpkgs.overlays      = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    boot.kernelPackages   = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

    nix.settings = {
      trusted-users      = [ "root" "@wheel" ];
      substituters       = [
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };

    environment.systemPackages = with pkgs; [
      neovim curl tree bat sbctl fastfetch btop equibop gnome-themes-extra
    ];
  };
}
