{ inputs, ... }: {
  perSystem = { pkgs, inputs', ... }: {
    packages.helium = pkgs.symlinkJoin {
      name = "helium";
      paths = [ inputs'.helium.packages.default ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/helium \
          --add-flags '--ozone-platform=wayland' \
          --add-flags '--enable-features=WaylandWindowDecorations' \
          --add-flags '--disable-features=UseChromeOSDirectVideoDecoder'
      '';
    };
  };

  flake.nixosModules.helium = { flakePackages, ... }: {
    environment.systemPackages = [ flakePackages.helium ];
  };
}
