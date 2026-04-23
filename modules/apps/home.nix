{ ... }: {
  flake.nixosModules.home = { pkgs, ... }: {
    home-manager.users.grey = { ... }: {

      home.username    = "grey";
      home.homeDirectory = "/home/grey";

      xresources.properties = {
        "Xcursor.size" = 16;
        "Xft.dpi"      = 172;
      };

      home.packages = with pkgs; [
        neovim
        curl
        tree
        bat
        fastfetch
        btop
        zip
        adwaita-icon-theme
        hicolor-icon-theme
      ];

      programs.git = {
        enable = true;

        settings.user = {
          name = "greyxp1";
          email = "greyxp999@gmail.com";
        };

        settings = {
          init.defaultBranch = "main";
          help.autocorrect = 1;
          column.ui = "auto";
          pull.rebase = true;
          branch.autosetuprebase = "always";
          push.autoSetupRemote = true;
          core.editor = "nvim";
          diff.algorithm = "histogram";
          merge.conflictstyle = "zdiff3";
          fetch.prune = true;
          fetch.all = true;

          alias = {
            lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            st = "status";
            co = "checkout";
            br = "branch";
          };
        };
      };

      programs.starship = {
        enable   = true;
        settings = {
          add_newline        = false;
          aws.disabled       = true;
          gcloud.disabled    = true;
          line_break.disabled = true;
        };
      };

      programs.bash = {
        enable           = true;
        enableCompletion = true;
        shellAliases = {
          rebuild = "sudo nixos-rebuild switch --flake ~/nixconf#main-pc";
          update  = "nix flake update --flake ~/nixconf";
        };
      };

      programs.ghostty = {
        enable                = true;
        enableBashIntegration = true;
        settings = {
          background-opacity = "0.81";
        };
      };

      programs.zed-editor = {
        enable = true;

        extensions = [
          "html"
          "git-firefly"
          "nix"
          "kdl"
        ];

        userSettings = {
          project_panel.button     = true;
          bottom_dock_layout       = "contained";
          collaboration_panel.dock = "left";
          toolbar.quick_actions    = true;

          telemetry = {
            diagnostics = false;
            metrics     = false;
          };

          session.trust_all_worktrees = true;

          ui_font_size     = 16;
          buffer_font_size = 15;
          theme            = "Noctalia Dark Transparent";
        };
      };

      home.stateVersion = "25.11";
    };
  };
}
