{ inputs, ... }: {
  flake.nixosModules.discord = { ... }: {
    home-manager.users.grey = { pkgs, ... }: {
      imports = [ inputs.nixcord.homeModules.nixcord ];

      programs.nixcord = {
        enable = true;

        config = {
          useQuickCss = true;
          plugins = {
            webScreenShareFixes.enable = true;
            voiceMessages.enable = true;
            blockKrisp.enable = true;
            alwaysTrust.enable = true;
            equibopStreamFixes.enable = true;
          };
        };

        equibop = {
          enable  = true;
          autoscroll.enable = true;
          package = pkgs.equibop.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
            postFixup = (old.postFixup or "") + ''
              wrapProgram $out/bin/equibop \
                --add-flags "--force_high_performance_gpu" \
                --add-flags "--enable-features=VaapiVideoDecodeLinuxGL" \
                #--add-flags "--start-minimized"
            '';
          });
          settings = {
            hardwareAcceleration = true;
            videoHardwareAcceleration = true;
            enableSplashScreen = false;
            splashTheming = false;
            middleClickAutoscroll = true;
            minimizeToTray = false;
          };
        };

        vesktop = {
          enable   = true;
          settings = {
            hardwareAcceleration = true;
            minimizeToTray = true;
          };
        };
      };
    };
  };
}
