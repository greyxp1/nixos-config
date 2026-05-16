{ inputs, ... }:
{
  flake.nixosModules.nixcord =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ inputs.nixcord.homeModules.nixcord ];

      home-manager.users.grey =
        { ... }:
        {
          programs.nixcord = {
            enable = true;
            discord.enable = false;

            equibop = {
              enable = true;
              state.firstLaunch = false;

              settings = {
                middleClickAutoscroll = true;
                tray = false;
                hardwareVideoAcceleration = true;
                enableSplashScreen = false;
                splashTheming = false;
                staticTitle = true;
              };

              package = pkgs.equibop.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
                postFixup = (old.postFixup or "") + ''
                  wrapProgram $out/bin/equibop \
                    --add-flags "--force_high_performance_gpu" \
                    --add-flags "--enable-features=VaapiVideoDecodeLinuxGL"
                '';
              });
            };

            quickCss = ''
              @import url("https://refact0r.github.io/midnight-discord/build/midnight.css");
              @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Apple.css);
              body {
                --remove-bg-layer: on;
                --top-bar-height: var(--gap);
              }
              :root { --bg-4: hsla(220, 15%, 10%, 0.81); }
            '';

            config = {
              useQuickCss = true;
              transparent = true;

              plugins = {
                alwaysTrust.enable = true;
                betterCommands.enable = true;
                betterSettings.enable = true;
                betterUploadButton.enable = true;
                ClearURLs.enable = true;
                disableCallIdle.enable = true;
                equibopStreamFixes.enable = true;
                expressionCloner.enable = true;
                fakeNitro.enable = true;
                fixFileExtensions.enable = true;
                fixImagesQuality.enable = true;
                fullSearchContext.enable = true;
                FullVCPFP.enable = true;
                guildPickerDumper.enable = true;
                hideMessages.enable = true;
                keepCurrentChannel.enable = true;
                memberCount.enable = true;
                messageClickActions.enable = true;
                messageTranslate.enable = true;
                micLoopbackTester.enable = true;
                newPluginsManager.enable = true;
                noMiddleClickPaste.enable = true;
                noNitroUpsell.enable = true;
                noOnboardingDelay.enable = true;
                noTypingAnimation.enable = true;
                noUnblockToJump.enable = true;
                OnePingPerDM.enable = true;
                pinIcon.enable = true;
                platformIndicators.enable = true;
                previewMessage.enable = true;
                relationshipNotifier.enable = true;
                remixRevived.enable = true;
                reverseImageSearch.enable = true;
                roleColorEverywhere.enable = true;
                showAllMessageButtons.enable = true;
                showTimeoutDuration.enable = true;
                userVoiceShow.enable = true;
                voiceRejoin.enable = true;
                webScreenShareFixes.enable = true;
                whosWatching.enable = true;
                zipPreview.enable = true;

                questify = {
                  enable = true;
                  allowChangingDangerousSettings = true;
                  autoCompleteQuestsSimultaneously = true;
                  completeVideoQuestsQuicker = true;
                  disableAccountPanelPromo = true;
                  disableAccountPanelQuestProgress = true;
                  disableFriendsListPromo = true;
                  disableMembersListPromo = true;
                  disableOrbsAndQuestsBadges = true;
                  disableSponsoredBanner = true;
                  makeMobileVideoQuestsDesktopCompatible = true;
                  questButtonDisplay = "unclaimed";
                  resumeInterruptedQuests = true;
                  autoCompleteQuestTypes = {
                    WATCH_VIDEO = true;
                    WATCH_VIDEO_ON_MOBILE = true;
                    ACHIEVEMENT_IN_ACTIVITY = true;
                  };
                };

                messageLoggerEnhanced = {
                  enable = true;
                  attachmentSizeLimitInMegabytes = 500;
                  cacheMessagesFromServers = true;
                  ignoreSelf = true;
                  messageLimit = 0;
                  saveImages = true;
                };

                voiceMessages = {
                  enable = true;
                  echoCancellation = false;
                  noiseSuppression = false;
                };

                imageZoom = {
                  enable = true;
                  square = true;
                  size = 500.0;
                };

                viewIcons = {
                  enable = true;
                  format = "png";
                  imgSize = "4096";
                };

                callTimer = {
                  enable = true;
                  format = "human";
                };

                declutter = {
                  enable = true;
                  removeShopAboveDM = true;
                };

                followVoiceUser = {
                  enable = true;
                  onlyWhenInVoice = false;
                };

                newGuildSettings = {
                  enable = true;
                  messages = 1;
                };

                quoter = {
                  enable = true;
                  watermark = "Made by greyxp1";
                };
              };
            };
          };
        };
    };
}
