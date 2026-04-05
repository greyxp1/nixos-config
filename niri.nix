{ pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.niri.homeModules.niri
  ];

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
}
