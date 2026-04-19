{ ... }: {
  flake.nixosModules.packages = { inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      neovim
      curl
      tree
      bat
      fastfetch
      btop
      zip
      adwaita-icon-theme
      hicolor-icon-theme
    ];
  };
}
