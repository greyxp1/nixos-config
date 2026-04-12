{ inputs, pkgs, lib, ... }:
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
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        polkit-agent = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        screen-recorder = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };

    settings = {
      appLauncher = {
        autoPasteClipboard = false;
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        density = "default";
        enableClipPreview = true;
        enableClipboardChips = true;
        enableClipboardHistory = true;
        enableClipboardSmartIcons = true;
        enableSessionSearch = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "native";
        ignoreMouseInput = false;
        overviewLayer = true;
        pinnedApps = [];
        position = "center";
        screenshotAnnotationTool = "";
        showCategories = false;
        showIconBackground = false;
        sortByMostUsed = true;
        terminalCommand = "alacritty -e";
        viewMode = "grid";
      };

      audio = {
        mprisBlacklist = [];
        preferredPlayer = "";
        spectrumFrameRate = 30;
        spectrumMirrored = true;
        visualizerType = "linear";
        volumeFeedback = false;
        volumeFeedbackSoundFile = "";
        volumeOverdrive = false;
        volumeStep = 5;
      };

      bar = {
        autoHideDelay = 500;
        autoShowDelay = 150;
        backgroundOpacity = 0.95;
        barType = "simple";
        capsuleColorKey = "none";
        capsuleOpacity = 1;
        contentPadding = 2;
        density = "default";
        displayMode = "always_visible";
        enableExclusionZoneInset = true;
        fontScale = 1;
        frameRadius = 12;
        frameThickness = 8;
        hideOnOverview = true;
        marginHorizontal = 4;
        marginVertical = 4;
        middleClickAction = "none";
        middleClickCommand = "";
        middleClickFollowMouse = false;
        monitors = [];
        mouseWheelAction = "none";
        mouseWheelWrap = true;
        outerCorners = true;
        position = "left";
        reverseScroll = false;
        rightClickAction = "controlCenter";
        rightClickCommand = "";
        rightClickFollowMouse = true;
        screenOverrides = [];
        showCapsule = false;
        showOnWorkspaceSwitch = true;
        showOutline = false;
        useSeparateOpacity = false;
        widgetSpacing = 6;
        widgets = {
          center = [
            {
              colorizeIcons = false;
              hideMode = "hidden";
              id = "ActiveWindow";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              showText = true;
              textColor = "none";
              useFixedWidth = false;
            }
          ];
          left = [
            {
              clockColor = "none";
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm";
              id = "Clock";
              tooltipFormat = "HH:mm ddd, MMM dd";
              useCustomFont = false;
            }
            {
              compactMode = true;
              diskPath = "/";
              iconColor = "none";
              id = "SystemMonitor";
              showCpuCores = false;
              showCpuFreq = false;
              showCpuTemp = false;
              showCpuUsage = true;
              showDiskAvailable = false;
              showDiskUsage = false;
              showDiskUsageAsPercent = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = false;
              showNetworkStats = false;
              showSwapUsage = false;
              textColor = "none";
              useMonospaceFont = true;
              usePadding = false;
            }
            {
              compactMode = false;
              hideMode = "hidden";
              hideWhenIdle = false;
              id = "MediaMini";
              maxWidth = 145;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              textColor = "none";
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          right = [
            {
              blacklist = [];
              chevronColor = "none";
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              id = "Tray";
              pinned = [];
            }
            {
              hideWhenZero = false;
              hideWhenZeroUnread = true;
              iconColor = "none";
              id = "NotificationHistory";
              showUnreadBadge = true;
              unreadBadgeColor = "primary";
            }
            {
              deviceNativePath = "__default__";
              displayMode = "graphic-clean";
              hideIfIdle = false;
              hideIfNotDetected = true;
              id = "Battery";
              showNoctaliaPerformance = false;
              showPowerProfiles = false;
            }
            {
              displayMode = "onhover";
              iconColor = "none";
              id = "Volume";
              middleClickCommand = "pwvucontrol || pavucontrol";
              textColor = "none";
            }
            {
              colorizeDistroLogo = false;
              colorizeSystemIcon = "none";
              customIconPath = "";
              enableColorization = false;
              icon = "noctalia";
              id = "ControlCenter";
              useDistroLogo = false;
            }
            {
              id = "plugin:screen-recorder";
            }
          ];
        };
      };

      brightness = {
        backlightDeviceMappings = [];
        brightnessStep = 5;
        enableDdcSupport = false;
        enforceMinimum = true;
      };

      calendar = {
        cards = [
          { enabled = true;  id = "calendar-header-card"; }
          { enabled = true;  id = "calendar-month-card"; }
          { enabled = true;  id = "weather-card"; }
        ];
      };

      colorSchemes = {
        darkMode = true;
        generationMethod = "tonal-spot";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        monitorForColors = "";
        predefinedScheme = "Catppuccin";
        schedulingMode = "off";
        syncGsettings = true;
        useWallpaperColors = false;
      };

      controlCenter = {
        cards = [
          { enabled = true;  id = "profile-card"; }
          { enabled = true;  id = "shortcuts-card"; }
          { enabled = true;  id = "audio-card"; }
          { enabled = false; id = "brightness-card"; }
          { enabled = true;  id = "weather-card"; }
          { enabled = true;  id = "media-sysmon-card"; }
        ];
        diskPath = "/";
        position = "bottom_right";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
            { id = "Notifications"; }
          ];
          right = [];
        };
      };

      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        gridSnapScale = false;
        monitorWidgets = [];
        overviewEnabled = true;
      };

      dock = {
        animationSpeed = 1;
        backgroundOpacity = 1;
        colorizeIcons = false;
        deadOpacity = 0.6;
        displayMode = "auto_hide";
        dockType = "floating";
        enabled = false;
        floatingRatio = 1;
        groupApps = false;
        groupClickAction = "cycle";
        groupContextMenuMode = "extended";
        groupIndicatorStyle = "dots";
        inactiveIndicators = false;
        indicatorColor = "primary";
        indicatorOpacity = 0.6;
        indicatorThickness = 3;
        launcherIcon = "";
        launcherIconColor = "none";
        launcherPosition = "end";
        launcherUseDistroLogo = false;
        monitors = [];
        onlySameOutput = true;
        pinnedApps = [];
        pinnedStatic = false;
        position = "bottom";
        showDockIndicator = false;
        showLauncherIcon = false;
        sitOnFrame = false;
        size = 1;
      };

      general = {
        allowPanelsOnScreenWithoutBar = true;
        allowPasswordWithFprintd = false;
        animationDisabled = false;
        animationSpeed = 1;
        autoStartAuth = false;
        avatarImage = "/etc/nixos/assets/user.jpg";
        boxRadiusRatio = 1;
        clockFormat = "hh\\nmm";
        clockStyle = "custom";
        compactLockScreen = false;
        dimmerOpacity = 0.2;
        enableBlurBehind = true;
        enableLockScreenCountdown = true;
        enableLockScreenMediaControls = false;
        enableShadows = true;
        forceBlackScreenCorners = true;
        iRadiusRatio = 1;
        keybinds = {
          keyDown  = [ "Down" ];
          keyEnter = [ "Return" "Enter" ];
          keyEscape = [ "Esc" ];
          keyLeft  = [ "Left" ];
          keyRemove = [ "Del" ];
          keyRight = [ "Right" ];
          keyUp    = [ "Up" ];
        };
        language = "";
        lockOnSuspend = true;
        lockScreenAnimations = false;
        lockScreenBlur = 0;
        lockScreenCountdownDuration = 10000;
        lockScreenMonitors = [];
        lockScreenTint = 0;
        passwordChars = false;
        radiusRatio = 1;
        reverseScroll = false;
        scaleRatio = 1;
        screenRadiusRatio = 1;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        showChangelogOnStartup = true;
        showHibernateOnLockScreen = false;
        showScreenCorners = true;
        showSessionButtonsOnLockScreen = false;
        smoothScrollEnabled = true;
        telemetryEnabled = false;
      };

      hooks = {
        colorGeneration = "";
        darkModeChange = "";
        enabled = false;
        performanceModeDisabled = "";
        performanceModeEnabled = "";
        screenLock = "";
        screenUnlock = "";
        session = "";
        startup = "";
        wallpaperChange = "";
      };

      idle = {
        customCommands = "[]";
        enabled = true;
        fadeDuration = 5;
        lockCommand = "";
        lockTimeout = 660;
        resumeLockCommand = "";
        resumeScreenOffCommand = "";
        resumeSuspendCommand = "";
        screenOffCommand = "";
        screenOffTimeout = 600;
        suspendCommand = "";
        suspendTimeout = 1800;
      };

      location = {
        analogClockInCalendar = true;
        autoLocate = true;
        firstDayOfWeek = -1;
        hideWeatherCityName = true;
        hideWeatherTimezone = false;
        name = "Laval";
        showCalendarEvents = true;
        showCalendarWeather = true;
        showWeekNumberInCalendar = false;
        use12hourFormat = true;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
        weatherTaliaMascotAlways = false;
      };

      network = {
        bluetoothAutoConnect = true;
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        bluetoothRssiPollIntervalMs = 60000;
        bluetoothRssiPollingEnabled = false;
        disableDiscoverability = false;
        networkPanelView = "wifi";
        wifiDetailsViewMode = "grid";
      };

      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = true;
        forced = true;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        nightTemp = "4000";
      };

      noctaliaPerformance = {
        disableDesktopWidgets = true;
        disableWallpaper = true;
      };

      notifications = {
        backgroundOpacity = 1;
        clearDismissed = true;
        criticalUrgencyDuration = 15;
        density = "default";
        enableBatteryToast = true;
        enableKeyboardLayoutToast = true;
        enableMarkdown = false;
        enableMediaToast = false;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        monitors = [];
        normalUrgencyDuration = 8;
        overlayLayer = true;
        respectExpireTimeout = false;
        saveToHistory = {
          critical = true;
          low = true;
          normal = true;
        };
        sounds = {
          criticalSoundFile = "";
          enabled = false;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          lowSoundFile = "";
          normalSoundFile = "";
          separateSounds = false;
          volume = 0.5;
        };
      };

      osd = {
        autoHideMs = 2000;
        backgroundOpacity = 1;
        enabled = true;
        enabledTypes = [ 0 1 2 ];
        location = "top_right";
        monitors = [];
        overlayLayer = true;
      };

      plugins = {
        autoUpdate = false;
        notifyUpdates = true;
      };

      sessionMenu = {
        countdownDuration = 3000;
        enableCountdown = true;
        largeButtonsLayout = "single-row";
        largeButtonsStyle = true;
        position = "center";
        showHeader = true;
        showKeybinds = true;
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
            keybind = "6";
          }
          {
            action = "userspaceReboot";
            command = "";
            countdownEnabled = true;
            enabled = false;
            keybind = "";
          }
        ];
      };

      settingsVersion = 59;

      systemMonitor = {
        batteryCriticalThreshold = 5;
        batteryWarningThreshold = 20;
        cpuCriticalThreshold = 90;
        cpuWarningThreshold = 80;
        criticalColor = "";
        diskAvailCriticalThreshold = 10;
        diskAvailWarningThreshold = 20;
        diskCriticalThreshold = 90;
        diskWarningThreshold = 80;
        enableDgpuMonitoring = true;
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        gpuCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        memCriticalThreshold = 90;
        memWarningThreshold = 80;
        swapCriticalThreshold = 90;
        swapWarningThreshold = 80;
        tempCriticalThreshold = 90;
        tempWarningThreshold = 80;
        useCustomColors = false;
        warningColor = "";
      };

      templates = {
        activeTemplates = [];
        enableUserTheming = false;
      };

      ui = {
        boxBorderEnabled = false;
        fontDefault = "Sans Serif";
        fontDefaultScale = 1;
        fontFixed = "monospace";
        fontFixedScale = 1;
        panelBackgroundOpacity = 0.93;
        panelsAttachedToBar = true;
        scrollbarAlwaysVisible = true;
        settingsPanelMode = "centered";
        settingsPanelSideBarCardStyle = false;
        tooltipsEnabled = true;
        translucentWidgets = false;
      };

      wallpaper = {
        automationEnabled = false;
        directory = "/etc/nixos/assets";
        enableMultiMonitorDirectories = false;
        enabled = true;
        favorites = [];
        fillColor = "#000000";
        fillMode = "crop";
        hideWallpaperFilenames = false;
        linkLightAndDarkWallpapers = true;
        monitorDirectories = [];
        overviewBlur = 0.4;
        overviewEnabled = false;
        overviewTint = 0.6;
        panelPosition = "follow_bar";
        randomIntervalSec = 300;
        setWallpaperOnAllMonitors = true;
        showHiddenFiles = false;
        skipStartupTransition = true;
        solidColor = "#1a1a2e";
        sortOrder = "name";
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.05;
        transitionType = [ "fade" "disc" "stripes" "wipe" "pixelate" "honeycomb" ];
        useOriginalImages = false;
        useSolidColor = false;
        useWallhaven = false;
        viewMode = "browse";
        wallhavenApiKey = "";
        wallhavenCategories = "111";
        wallhavenOrder = "desc";
        wallhavenPurity = "100";
        wallhavenQuery = "";
        wallhavenRatios = "";
        wallhavenResolutionHeight = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenSorting = "relevance";
        wallpaperChangeMode = "random";
      };
    };

    colors = {
      mError           = "#f38ba8";
      mHover           = "#94e2d5";
      mOnError         = "#11111b";
      mOnHover         = "#11111b";
      mOnPrimary       = "#11111b";
      mOnSecondary     = "#11111b";
      mOnSurface       = "#cdd6f4";
      mOnSurfaceVariant = "#a3b4eb";
      mOnTertiary      = "#11111b";
      mOutline         = "#4c4f69";
      mPrimary         = "#cba6f7";
      mSecondary       = "#fab387";
      mShadow          = "#11111b";
      mSurface         = "#1e1e2e";
      mSurfaceVariant  = "#313244";
      mTertiary        = "#94e2d5";
    };
  };
}
