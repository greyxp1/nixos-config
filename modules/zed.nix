{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.zed = pkgs.symlinkJoin {
      name = "zed-editor";
      paths = [ pkgs.zed-editor ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/zeditor \
          --set WAYLAND_DISPLAY "$WAYLAND_DISPLAY" \
          --set XDG_SESSION_TYPE "wayland"
      '';
    };
  };

  flake.nixosModules.zed = { flakePackages, ... }: {
    environment.systemPackages = [ flakePackages.zed ];
  };
}
