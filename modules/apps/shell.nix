{ ... }:
{
  flake.nixosModules.shell =
    { ... }:
    {
      home-manager.users.grey =
        { ... }:
        {
          programs.starship = {
            enable = true;
            settings = {
              add_newline = false;
              aws.disabled = true;
              gcloud.disabled = true;
              line_break.disabled = true;
            };
          };

          programs.bash = {
            enable = true;
            enableCompletion = true;
            shellAliases = {
              rebuild = "nh os switch && sudo systemctl restart home-manager-grey.service";
              update = "nh os switch --update && sudo systemctl restart home-manager-grey.service";
            };
          };
        };
    };
}
