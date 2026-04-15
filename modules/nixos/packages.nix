{ ... }: {
  flake.nixosModules.packages = { inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      neovim
      curl
      tree
      bat
      fastfetch
      btop
      equibop
      zip
      inputs.helium.packages.${pkgs.system}.default
    ];
  };
}
