{ inputs, ... }:
{
  flake.nixosModules.core =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        inputs.disko.nixosModules.disko
      ];

      time.timeZone = "America/Montreal";
      networking.networkmanager.enable = true;
      nixpkgs.config.allowUnfree = true;
      security.polkit.enable = true;

      system = {
        nixos.label = config.networking.hostName;
        stateVersion = "25.11";
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
      };

      users.users.grey = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
          "input"
          "libvirtd"
          "seat"
        ];
        initialPassword = "123";
      };

      nix.settings = {
        trusted-users = [
          "root"
          "@wheel"
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      stylix = {
        enable = true;
        autoEnable = true;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        image = inputs.self + "/assets/wallpapers/wheat.jpg";

        cursor = {
          package = pkgs.catppuccin-cursors.mochaMauve;
          name = "catppuccin-mocha-mauve-cursors";
          size = 24;
        };
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.grey =
          { ... }:
          {
            gtk.gtk4.theme = null;
            home = {
              username = "grey";
              homeDirectory = "/home/grey";
              stateVersion = "25.11";
            };
          };
      };

      xdg = {
        portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
          ];
          config.niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
        };

        mime.defaultApplications = {
          #"x-scheme-handler/http"  = "helium.desktop";
          #"x-scheme-handler/https" = "helium.desktop";
          #"text/html"              = "helium.desktop";
          #"inode/directory"        = "thunar.desktop";
          #"x-scheme-handler/file"  = "thunar.desktop";
        };
      };

      environment = {
        pathsToLink = [ "/share/applications" ];
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
          MOZ_ENABLE_WAYLAND = "1"; # Firefox and Thunderbird
          XDG_CURRENT_DESKTOP = "niri";
        };
      };

      hardware = {
        enableRedistributableFirmware = true;
        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu.swtpm.enable = true;
          qemu.verbatimConfig = ''
            cgroup_device_acl = [
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm",
              "/dev/dri/card1",
              "/dev/dri/renderD128"
            ]
          '';
        };

        vmVariant = {
          spiceUSBRedirection.enable = true;
          virtualisation.qemu.options = [
            "-device virtio-vga-gl"
            "-display gtk,gl=on"
            "-cpu host"
          ];
        };
      };
    };
}
