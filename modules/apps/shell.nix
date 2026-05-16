{ ... }:
{
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "/home/grey/nixconf";
        clean = {
          enable = true;
          extraArgs = "--keep-since 2d --keep 3";
        };
      };

      users.users.grey.shell = pkgs.nushell;

      home-manager.users.grey =
        { ... }:
        {
          programs.nushell = {
            enable = true;
            environmentVariables.PAGER = "bat";
            settings.show_banner = false;
            shellAliases = {
              rebuild = "nh os switch";
              update = "nh os switch --update";
              home = "sudo systemctl restart home-manager-grey.service";
              clean = "nh clean all";
              cdi = "__zoxide_zi";
              tree = "lstr -g --icons --git-status";
              treell = "lstr -a -s -p --icons";
              treei = "lstr interactive -g --icons --git-status";
            };
          };

          programs.zoxide = {
            enable = true;
            enableNushellIntegration = true;
            options = [ "--cmd cd" ];
          };

          programs.carapace = {
            enable = true;
            enableNushellIntegration = true;
          };

          programs.starship = {
            enable = true;
            enableNushellIntegration = true;
            settings = {
              add_newline = false;
              aws.disabled = true;
              gcloud.disabled = true;
              line_break.disabled = true;
            };
          };

          home.packages = with pkgs; [
            curl
            lstr
            bat
            fastfetch
            btop
            zip
            unzip
            wget
            codex
            nerd-fonts.jetbrains-mono
            fzf
          ];
        };
    };
}
