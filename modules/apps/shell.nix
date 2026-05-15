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

          programs.nushell = {
            enable = true;

            extraConfig = "$env.config.show_banner = false";

            shellAliases = {
              rebuild = "nh os switch";
              update = "nh os switch --update";
              home = "sudo systemctl restart home-manager-grey.service";
            };
          };
        };
    };
}
