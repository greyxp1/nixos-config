{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    # .wrap accepts either a plain attrset or a function.
    # Using a plain attrset is simplest — pkgs is already in scope above.
    (inputs.ghosttyWrappers.wrappers.ghostty.wrap {
      inherit pkgs;
      settings = {
        theme             = "dark";
        font-family       = "JetBrainsMono Nerd Font";
        window-decoration = false;
        cursor-style      = "block";
      };
    })
  ];
}
