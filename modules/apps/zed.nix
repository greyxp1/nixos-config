{ ... }:
{
  flake.nixosModules.zed =
    { ... }:
    {
      home-manager.users.grey =
        { ... }:
        {
          programs.zed-editor = {
            enable = true;

            extensions = [
              "html"
              "git-firefly"
              "nix"
              "kdl"
            ];

            userSettings = {
              theme = "Noctalia Dark Transparent";
              session.trust_all_worktrees = true;
              collaboration_panel.button = false;
              project_panel.dock = "left";
              git_panel.dock = "left";

              telemetry = {
                diagnostics = false;
                metrics = false;
              };

              agent = {
                sidebar_side = "right";
                dock = "right";
              };
            };
          };
        };
    };
}
