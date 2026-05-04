{ ... }:
{
  # Declaratively define the NixOS test VM for grey's user session.
  # Uses qemu:///session so QEMU inherits the Wayland env → host EGL works.
  # Run `virsh -c qemu:///session start nixos-vm` to boot it.
  home-manager.users.grey =
    { lib, pkgs, ... }:
    {
      home.activation.defineNixosVm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        VM_NAME="nixos-vm"
        VM_DIR="$HOME/.local/share/libvirt/images"
        VM_XML="$HOME/.local/share/libvirt/nixos-vm.xml"
        DISK="$VM_DIR/$VM_NAME.qcow2"

        install -d -m 0755 "$VM_DIR"

        # Create disk image if it doesn't exist
        if [ ! -f "$DISK" ]; then
          ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$DISK" 40G
        fi

        # Write VM XML
        cat > "$VM_XML" << XMLEOF
<domain type='kvm'>
  <name>nixos-vm</name>
  <memory unit='GiB'>4</memory>
  <currentMemory unit='GiB'>4</currentMemory>
  <vcpu placement='static'>4</vcpu>
  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
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
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
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
    <controller type='pci' index='4' model='pcie-root-port'/>

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

    <redirdev bus='usb' type='spicevmc'/>
    <redirdev bus='usb' type='spicevmc'/>

    <memballoon model='virtio'/>
    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>
  </devices>
</domain>
XMLEOF

        # Define/redefine VM (idempotent)
        ${pkgs.libvirt}/bin/virsh -c qemu:///session define "$VM_XML" > /dev/null
      '';
    };
}
