{ config, pkgs, lib, inputs, ... }:

{
  home.username = "grey";
  home.homeDirectory = "/home/grey";

  home.packages = with pkgs; [
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

  home.stateVersion = "24.11";
}
