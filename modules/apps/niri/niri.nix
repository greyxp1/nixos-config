{ inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      imports = [
        inputs.niri.nixosModules.niri
        inputs.niri-autoselect-portal.nixosModules.default
      ];

      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
      };

      services.niri-autoselect-portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      home-manager.sharedModules = [
        {
          programs.niri.config = builtins.readFile ./config.kdl;
          home.packages = [
            inputs.niri-float-sticky.packages.${pkgs.stdenv.hostPlatform.system}.default
            (pkgs.writeShellScriptBin "screencast-monitor" (builtins.readFile ./screencast-monitor.sh))
            (pkgs.writeShellScriptBin "tile-to-2" ''
              exec ${pkgs.python3}/bin/python3 ${./tile-to-2.py} -n 2 -m "$@"
            '')
          ];
        }
      ];
    };
}
