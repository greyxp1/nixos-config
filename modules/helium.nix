{ inputs, pkgs, lib, ... }:
let
  helium = inputs.helium.packages.${pkgs.system}.default;

  # Flags passed to Helium on every launch.
  # Add/remove as needed — these are standard Chromium flags.
  flags = [
    "--ozone-platform=wayland"        # Native Wayland rendering under niri
    "--enable-features=WaylandWindowDecorations"
    "--disable-features=UseChromeOSDirectVideoDecoder"
  ];

  wrappedHelium = pkgs.symlinkJoin {
    name = "helium";
    paths = [ helium ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/helium \
        ${lib.concatMapStringsSep " \\\n        " (f: "--add-flags '${f}'") flags}
    '';
  };
in {
  environment.systemPackages = [ wrappedHelium ];
}
