{ inputs, ... }: {
  flake.nixosModules.equibop = { ... }: {
    home-manager.users.grey = { pkgs, ... }: {
      imports = [ inputs.nixcord.homeModules.nixcord ];

      programs.nixcord = {
        enable = true;
        quickCss = builtins.readFile ./quickCss.css;
        config = {
          useQuickCss = true;
          frameless = true;
          transparent = true;
          plugins = {
            alwaysTrust.enable = true;
            autoZipper.enable = true;
            betterSettings.enable = true;
            betterUploadButton.enable = true;
            blockKrisp.enable = true;
            callTimer.enable = true;
            ClearURLs.enable = true;
            declutter.enable = true;
            equibopStreamFixes.enable = true;
            fixFileExtensions.enable = true;
            fixImagesQuality.enable = true;
            followVoiceUser.enable = true;
            fullSearchContext.enable = true;
            FullVCPFP.enable = true;
            imageZoom.enable = true;
            messageLogger = {
              enable = true;
              ignoreSelf = true;
            };
            micLoopbackTester.enable = true;
            voiceMessages.enable = true;
            webScreenShareFixes.enable = true;
          };
        };

        equibop = {
          enable  = true;
          package = pkgs.equibop.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
            postFixup = (old.postFixup or "") + ''
              wrapProgram $out/bin/equibop \
                --add-flags "--force_high_performance_gpu" \
                --add-flags "--enable-features=VaapiVideoDecodeLinuxGL" \
                #--add-flags "--start-minimized"
            '';
          });
          autoscroll.enable = true;
          state = {
            firstLaunch = false;
          };

          settings = {
            hardwareAcceleration = true;
            hardwareVideoAcceleration = true;
            enableSplashScreen = false;
            splashTheming = false;
            middleClickAutoscroll = true;
            minimizeToTray = false;
            tray = false;
          };
        };
      };
    };
  };
}
