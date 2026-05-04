{ ... }:
{
  flake.nixosModules.virsh =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.networking.hostName == "main-pc") {
        home-manager.users.grey =
          { lib, pkgs, ... }:
          {
            systemd.user.services.define-nixos-vm = {
              Unit = {
                Description = "Define nixos-vm in libvirt user session";
                After = [ "default.target" ];
              };
              Service = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "define-nixos-vm" ''
                                    VM_DIR="$HOME/.local/share/libvirt/images"
                                    VM_XML="$HOME/.local/share/libvirt/nixos-vm.xml"
                                    DISK="$VM_DIR/nixos-vm.qcow2"

                                    mkdir -p "$VM_DIR"
                                    mkdir -p "$HOME/.local/share/libvirt/qemu/nvram"
                                    NVRAM="$HOME/.local/share/libvirt/qemu/nvram/nixos-vm_VARS.fd"
                                    if [ ! -f "$NVRAM" ]; then
                                      cp /run/libvirt/nix-ovmf/OVMF_VARS.fd "$NVRAM"
                                      chmod 600 "$NVRAM"
                                    fi

                                    if [ ! -f "$DISK" ]; then
                                      ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$DISK" 40G
                                    fi

                                    cat > "$VM_XML" << XMLEOF
                  <domain type='kvm'>
                    <name>nixos-vm</name>
                    <memory unit='GiB'>4</memory>
                    <currentMemory unit='GiB'>4</currentMemory>
                    <vcpu placement='static'>4</vcpu>
                    <os>
                      <type arch='x86_64' machine='q35'>hvm</type>
                      <loader readonly='yes' type='pflash'>/run/libvirt/nix-ovmf/OVMF_CODE.fd</loader>
                      <nvram template='/run/libvirt/nix-ovmf/OVMF_VARS.fd'>$HOME/.local/share/libvirt/qemu/nvram/nixos-vm_VARS.fd</nvram>
                      <boot dev='cdrom'/>
                      <boot dev='hd'/>
                    </os>
                    <features>
                      <acpi/>
                      <apic/>
                    </features>
                    <cpu mode='host-passthrough' check='none' migratable='on'/>
                    <clock offset='utc'>
                      <timer name='rtc' tickpolicy='catchup'/>
                      <timer name='pit' tickpolicy='delay'/>
                      <timer name='hpet' present='no'/>
                    </clock>
                    <on_poweroff>destroy</on_poweroff>
                    <on_reboot>restart</on_reboot>
                    <on_crash>destroy</on_crash>
                    <devices>
                      <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
                      <disk type='file' device='disk'>
                        <driver name='qemu' type='qcow2' discard='unmap'/>
                        <source file='$DISK'/>
                        <target dev='vda' bus='virtio'/>
                      </disk>
                      <controller type='usb' index='0' model='qemu-xhci' ports='15'/>
                      <controller type='pci' index='0' model='pcie-root'/>
                      <controller type='pci' index='1' model='pcie-root-port'/>
                      <controller type='pci' index='2' model='pcie-root-port'/>
                      <controller type='pci' index='3' model='pcie-root-port'/>
                      <interface type='user'>
                        <mac address='52:54:00:ab:cd:ef'/>
                        <model type='virtio'/>
                      </interface>
                      <channel type='spicevmc'>
                        <target type='virtio' name='com.redhat.spice.0'/>
                      </channel>
                      <input type='tablet' bus='usb'/>
                      <input type='keyboard' bus='usb'/>
                      <graphics type='spice'>
                        <listen type='none'/>
                        <image compression='off'/>
                        <gl enable='yes' rendernode='/dev/dri/renderD128'/>
                      </graphics>
                      <sound model='ich9'/>
                      <audio id='1' type='spice'/>
                      <video>
                        <model type='virtio' heads='1' primary='yes'>
                          <acceleration accel3d='yes'/>
                        </model>
                      </video>
                      <disk type='file' device='cdrom'>
                        <driver name='qemu' type='raw'/>
                        <source file='/home/grey/Downloads/nixos-25.11.iso'/>
                        <target dev='sda' bus='sata'/>
                        <readonly/>
                      </disk>
                      <serial type='pty'>
                        <target type='isa-serial' port='0'/>
                      </serial>
                      <console type='pty'>
                        <target type='serial' port='0'/>
                      </console>
                      <redirdev bus='usb' type='spicevmc'/>
                      <redirdev bus='usb' type='spicevmc'/>
                      <memballoon model='virtio'/>
                      <rng model='virtio'>
                        <backend model='random'>/dev/urandom</backend>
                      </rng>
                    </devices>
                  </domain>
                  XMLEOF

                                    ${pkgs.libvirt}/bin/virsh -c qemu:///session undefine nixos-vm 2>/dev/null || true
                                    ${pkgs.libvirt}/bin/virsh -c qemu:///session define "$VM_XML"
                '';
              };
              Install.WantedBy = [ "default.target" ];
            };
          };
      };
    };
}
