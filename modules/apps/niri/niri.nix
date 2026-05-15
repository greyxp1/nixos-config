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
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
      xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];

      home-manager.sharedModules = [
        {
          programs.niri.config = builtins.readFile ./config.kdl;
          home.packages = [
            inputs.niri-float-sticky.packages.${pkgs.stdenv.hostPlatform.system}.default
            (pkgs.writeShellScriptBin "screencast-monitor" (builtins.readFile ./screencast-monitor.sh))
          ];

          xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
            [filechooser]
            cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
            default_dir=$HOME
            env=TERMCMD=kitty --class yazi-filepicker
          '';
        }
      ];
    };
}
