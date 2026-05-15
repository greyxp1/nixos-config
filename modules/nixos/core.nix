{ inputs, ... }:
{
  flake.nixosModules.core =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.catppuccin.nixosModules.catppuccin
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
        shell = pkgs.nushell;
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

      catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "mauve";
        cache.enable = true;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        sharedModules = [
          inputs.catppuccin.homeModules.catppuccin
        ];
        users.grey =
          { pkgs, ... }:
          {
            home = {
              username = "grey";
              homeDirectory = "/home/grey";
              stateVersion = "26.05";
              pointerCursor = {
                package = pkgs.catppuccin-cursors.mochaMauve;
                name = "catppuccin-mocha-mauve-cursors";
                size = 24;
                gtk.enable = true;
              };
            };
            catppuccin = {
              enable = true;
              flavor = "mocha";
              accent = "mauve";
            };
          };
      };

      services = {
        greetd = {
          enable = true;
          useTextGreeter = true;
          restart = false;
          settings.default_session = {
            command = "niri-session";
            user = "grey";
          };
        };
        flatpak.enable = true;
        upower.enable = true;
        power-profiles-daemon.enable = true;
        dbus.enable = true;
        gvfs.enable = true;
      };

      environment = {
        pathsToLink = [ "/share/applications" ];
        sessionVariables = {
          GTK_USE_PORTAL = "1";
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
