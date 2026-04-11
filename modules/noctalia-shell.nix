{ inputs, ... }:
{
  imports = [
    (inputs.wrappers.lib.mkInstallModule {
      name  = "noctalia-shell";
      value = inputs.wrappers.lib.wrapperModules.noctalia-shell;
    })
  ];

  wrappers.noctalia-shell = {
    enable = true;
    outOfStoreConfig = "/home/grey/.config/noctalia";

    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        polkit-agent = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };

    # Seed the initial settings — these get copied out to the mutable location
    # on first launch. After that, the GUI writes to the mutable location directly.
    settings = {
      bar = {
        position = "top";
        floating = true;
        backgroundOpacity = 0.95;
      };
      general = {
        animationSpeed = 1.0;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
      };
      sessionMenu = {
        countdownDuration = 3000;
        enableCountdown = true;
        position = "center";
        showHeader = true;
        powerOptions = [
          {
            action = "lock";
            command = "";
            countdownEnabled = false;
            enabled = true;
            keybind = "Shift+L";
          }
          {
            action = "logout";
            command = "/run/current-system/sw/bin/niri msg action quit --skip-confirmation";
            countdownEnabled = false;
            enabled = true;
            keybind = "L";
          }
          {
            action = "reboot";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "R";
          }
          {
            action = "shutdown";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "S";
          }
          {
            action = "suspend";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "Shift+S";
          }
          {
            action = "hibernate";
            command = "";
            countdownEnabled = true;
            enabled = false;
            keybind = "";
          }
          {
            action = "rebootToUefi";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "";
          }
        ];
      };
      colorSchemes = {
        darkMode = true;
      };
    };

    colors = {
      mPrimary         = "#cba6f7";
      mSecondary       = "#89b4fa";
      mTertiary        = "#a6e3a1";
      mSurface         = "#1e1e2e";
      mSurfaceVariant  = "#313244";
      mOnSurface       = "#cdd6f4";
      mOnSurfaceVariant = "#bac2de";
      mOutline         = "#45475a";
      mError           = "#f38ba8";
      mOnPrimary       = "#1e1e2e";
      mOnSecondary     = "#1e1e2e";
      mOnTertiary      = "#1e1e2e";
      mOnError         = "#1e1e2e";
      mShadow          = "#000000";
    };
  };
}
