{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    (inputs.ghosttyWrappers.wrappers.ghostty.wrap ({ inherit pkgs; ... }: {
      settings = {
        theme                = "dark";
        font-family          = "JetBrainsMono Nerd Font";
        window-decoration    = false;
        cursor-style         = "block";
      };
    }))
  ];
}
