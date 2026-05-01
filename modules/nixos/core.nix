{ inputs, ... }: {
  flake.nixosModules.core = { config, pkgs, lib, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.catppuccin.nixosModules.catppuccin
      inputs.disko.nixosModules.disko
    ];

    time.timeZone = "America/Montreal";
    networking.networkmanager.enable = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };

    users.users.grey = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "video" "input" "libvirtd" ];
      initialPassword = "123";
    };

    nix.settings = {
      trusted-users = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
    };

    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
      cursors.enable = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.grey = { ... }: {
        home = {
          username = "grey";
          homeDirectory = "/home/grey";
          stateVersion = "25.11";
        };
      };
    };

    environment.pathsToLink = [ "/share/applications" ];

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        config.niri = {
          default = [ "gnome" "gtk" ];
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

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      MOZ_ENABLE_WAYLAND = "1"; #Firefox and Thunderbird
      XDG_CURRENT_DESKTOP = "niri";
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };

      vmVariant = {
        virtualisation.qemu.options = [
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
          "-cpu host"
        ];
      };

      spiceUSBRedirection.enable = true;
    };

    system.nixos.label = config.networking.hostName;
    security.polkit.enable = true;
    system.stateVersion = "25.11";
  };
}
