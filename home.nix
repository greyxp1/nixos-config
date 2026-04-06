{ config, pkgs, inputs, ... }:

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

  programs.ghostty = {
    enable = true;
  };

  programs.niri = {
    enable = true;
    settings = {
      input.keyboard.xkb.layout = "us,ua";
      layout.gaps = 5;
      binds = {
        "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
        "Mod+Q".close-window = null;
      };
    };
  };

  programs.noctalia = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
