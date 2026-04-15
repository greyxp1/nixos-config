{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.zed = pkgs.symlinkJoin {
      name       = "zed-editor";
      paths      = [ pkgs.zed-editor ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild  = ''
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
          project_panel.button    = true;
          bottom_dock_layout      = "contained";
          collaboration_panel.dock = "left";
          toolbar.quick_actions   = true;

          telemetry = {
            diagnostics = false;
            metrics     = false;
          };

          session.trust_all_worktrees = true;

          ui_font_size     = 16;
          buffer_font_size = 15;
          theme             = "Ayu Dark";
        };
      };
    };
  };
}
