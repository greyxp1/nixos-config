{ ... }:
{
  flake.nixosModules.shell =
    { ... }:
    {
      programs.fish.enable = true;

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

          programs.fish = {
            enable = true;
            interactiveShellInit = "set -g fish_greeting";

            functions = {
              rebuild = "nh os switch";
              update = "nh os switch --update";
              hmswitch = "sudo systemctl restart home-manager-grey.service";
            };
          };
        };
    };
}
