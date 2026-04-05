{ config, pkgs, intputs, ... }:

{
  imports = [
    intputs.noctalia.homeModules.default
    ./niri.nix
  ];

  home.username = "grey";
  home.homeDirectory = "/home/grey";

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    tree
  ];

  programs.noctalia-shell.enable = true;

  programs.git.settings = {
    enable = true;
    userName = "greyxp1";
    userEmail = "greyxp999@gmail.com";
    init.defaultBranch = "main";
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  home.stateVersion = "25.11";
}
