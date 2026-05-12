{ inputs, ... }:
{
  flake.nixosModules.noctalia-v5 =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      home-manager.users.grey = {
        home.file.".config/noctalia/config.toml".text = ''
          [shell]
          avatar_path = "/home/grey/nixconf/assets/user.jpg"
          password_style = "random"
          polkit_agent = false
          settings_show_advanced = true
          show_location = false

          [shell.panel]
          attach_control_center = false

          [theme]
          builtin = "Catppuccin"
          community_palette = "ADW"

          [theme.templates]
          builtin_ids = ["niri", "ghostty", "btop"]

          [wallpaper]
          directory = "/home/grey/nixconf/assets/wallpapers"

          [wallpaper.default]
          path = "/home/grey/nixconf/assets/wallpapers/wheat.jpg"

          [wallpaper.monitors.DP-3]
          path = "/home/grey/nixconf/assets/wallpapers/wheat.jpg"

          [bar.default]
          position = "left"
          enabled = false
          background_opacity = 0.9
          margin_h = 10
          margin_edge = 0
          margin_ends = 0
          radius_bottom_left = 0
          radius_top_left = 0
          center = ["workspaces"]
          start = ["clock", "launcher"]

          [dock]
          position = "bottom"

          [notification]
          background_opacity = 0.81

          [desktop_widgets]
          enabled = false

          [weather]
          auto_locate = true

          [widget.workspaces]
          display = "none"
        '';
      };
    };
}
