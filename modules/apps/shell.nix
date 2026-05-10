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
              rebuild = "nh os switch --no-nom $argv 2>&1 | grep -v '^/nix/store/' | awk '/^<<</{p=1} p'; set -l st $pipestatus[1]; return $st";
              update = "nh os switch --update --no-nom $argv 2>&1 | grep -v '^/nix/store/' | awk '/^<<</{p=1} p'; set -l st $pipestatus[1]; return $st";
            };

            shellAliases = {
              hmswitch = "sudo systemctl restart home-manager-grey.service";
            };
          };
        };
    };
}
