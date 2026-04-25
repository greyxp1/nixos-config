{ ... }: {
  flake.nixosModules.core = { config, pkgs, lib, ... }: {
    time.timeZone                          = "America/Montreal";
    networking.networkmanager.enable       = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree            = true;

    zramSwap = {
      enable    = true;
      algorithm = "zstd";
    };

    users.users.grey = {
      isNormalUser    = true;
      extraGroups     = [ "networkmanager" "wheel" "video" "input" "libvirtd" ];
      initialPassword = "123";
    };

    nix.settings = {
      trusted-users         = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];

      substituters        = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7SwKTPnCQST63SSTtmdclW2K89XSTmB5V9sMo=" ];
    };

    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
      cursors.enable = true;
    };

    home-manager.useGlobalPkgs   = true;
    home-manager.useUserPackages = true;
    environment.pathsToLink = [ "/share/applications" ];

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.niri.default = lib.mkForce "gnome;gtk";
      };

      mime.defaultApplications = {
        "x-scheme-handler/http"  = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "text/html"              = "helium.desktop";
      };
    };

    environment.sessionVariables = {
      #GCM_CREDENTIAL_STORE = "secretservice";
      #GIT_TERMINAL_PROMPT = "1";
      NIXOS_OZONE_WL              = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      MOZ_ENABLE_WAYLAND          = "1";
      XDG_CURRENT_DESKTOP         = "niri";
    };

    hardware.graphics = {
      enable      = true;
      enable32Bit = true;
    };

    services = {
      greetd = {
        enable   = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user    = "greeter";
        };
      };

      pipewire = {
        enable       = true;
        alsa.enable  = true;
        pulse.enable = true;
      };

      flatpak.enable = true;
      upower.enable = true;
      power-profiles-daemon.enable = true;
      gnome.gnome-keyring.enable = true;
      dbus.enable = true;
    };

    security.pam.services.greetd.enableGnomeKeyring = true;

    virtualisation = {
      libvirtd = {
        enable           = true;
        qemu.swtpm.enable = true;
      };
      spiceUSBRedirection.enable = true;
    };

    system.nixos.label     = config.networking.hostName;
    security.polkit.enable = true;
    system.stateVersion    = "25.11";
  };
}
