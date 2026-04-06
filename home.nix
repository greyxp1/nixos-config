{ config, pkgs, lib, inputs, ... }:

{
  home.username = "grey";
  home.homeDirectory = "/home/grey";

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    tree
  ];

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "greyxp1";
        email = "greyxp999@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
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

  programs.ghostty.enable = true;

  programs.niri = {
    enable = true;
    settings = {
      input.keyboard.xkb.layout = "us,ua";
      layout.gaps = 5;
      binds = {
        "Mod+Return".action.spawn = [ (lib.getExe pkgs.ghostty) ];
        "Mod+Q".action.close-window = [];
      };
    };
  };

  programs.noctalia-shell.enable = true;

  home.stateVersion = "24.11";
}
