{ ... }:
{
  flake.nixosModules.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        virt-manager
        #virt-viewer
        spice
        spice-gtk
        spice-protocol
        #virtio-win
        #win-spice
      ];

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
