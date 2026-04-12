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

    home-manager.users.grey = { ... }: {
      home.stateVersion = "23.11";

      programs.zed-editor = {
        enable = true;

        extensions = [
          "html"
          "git-firefly"
          "nix"
        ];

        userSettings = {
          theme = {
            mode = "dark";
            dark = "Ayu Dark";
          };
          auto_update          = false;
          confirm_quit         = false;
          session_restore      = "none";
          project_panel        = { default_width = 240; };
          # Trust all projects without asking
          git_status           = true;
          load_direnv          = "shell_hook";

          # Trust all projects by default — disables the trust prompt on open
          trusted_workspaces = { level = "trusted"; };
        };
      };
    };
  };
}
