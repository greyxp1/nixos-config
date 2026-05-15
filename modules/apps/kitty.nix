{ ... }:
{
  flake.nixosModules.kitty =
    { ... }:
    {
      home-manager.users.grey =
        { ... }:
        {
          programs.kitty = {
            enable = true;

            font = {
              name = "JetBrainsMono Nerd Font";
              size = 13;
            };

            settings = {
              cursor_shape = "beam";
              cursor_blink_interval = 0;
              cursor_trail = 4;
              cursor_trail_decay = "0.1 0.4";
              cursor_trail_start_threshold = 2;
              bold_font = "JetBrainsMono Nerd Font Bold";
              italic_font = "JetBrainsMono Nerd Font Italic";
              bold_italic_font = "JetBrainsMono Nerd Font Bold Italic";
              background_opacity = "0.81";
              window_padding_width = 12;
              detect_urls = true;
              tab_bar_style = "powerline";
              tab_powerline_style = "slanted";
              enable_audio_bell = false;
              strip_trailing_spaces = "smart";
              scrollback_lines = 10000;
            };
          };
        };
    };
}
