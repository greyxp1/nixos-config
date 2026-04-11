#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/greyxp1/nixos-config.git"
FLAKE_ATTR="nixos"
WORK_DIR="/tmp/nixos-config"

# ── 1. Clone config ───────────────────────────────────────────────────────────
echo "Fetching config..."
rm -rf "$WORK_DIR"
git clone -q "$REPO" "$WORK_DIR"
cd "$WORK_DIR"

# ── 2. Disk selection ─────────────────────────────────────────────────────────
ISO_SOURCE=$(findmnt -n -o SOURCE /iso 2>/dev/null || true)
ISO_DISK=""
[[ -n "$ISO_SOURCE" ]] && ISO_DISK=$(lsblk -no PKNAME "$ISO_SOURCE" 2>/dev/null || true)

mapfile -t DISK_NAMES < <(
  lsblk -dn -o NAME,TYPE -e 7 \
    | awk '$2=="disk"{print $1}' \
    | grep -v "^${ISO_DISK}$" \
  || true
)
[[ ${#DISK_NAMES[@]} -eq 0 ]] && { echo "ERROR: No eligible disks found."; exit 1; }

if [[ ${#DISK_NAMES[@]} -eq 1 ]]; then
  DEV="/dev/${DISK_NAMES[0]}"
  echo "Disk: $DEV  $(lsblk -dno SIZE "$DEV")  $(lsblk -dno MODEL "$DEV")"
else
  echo "Available disks:"
  for i in "${!DISK_NAMES[@]}"; do
    printf "  [%d] /dev/%s  %s  %s\n" "$i" \
      "${DISK_NAMES[$i]}" \
      "$(lsblk -dno SIZE  "/dev/${DISK_NAMES[$i]}")" \
      "$(lsblk -dno MODEL "/dev/${DISK_NAMES[$i]}")"
  done
  exec < /dev/tty
  read -rp "Install to disk (number): " CHOICE
  [[ -z "${DISK_NAMES[$CHOICE]+x}" ]] && { echo "ERROR: Invalid choice."; exit 1; }
  DEV="/dev/${DISK_NAMES[$CHOICE]}"
  read -rp "DANGER: This will WIPE $DEV. Are you sure? (y/n): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

# ── 3. Detect firmware ────────────────────────────────────────────────────────
if [[ -d /sys/firmware/efi/efivars ]]; then UEFI=true; else UEFI=false; fi
echo "Firmware: $($UEFI && echo UEFI || echo BIOS/Legacy)"

# ── 4. Partition and format ───────────────────────────────────────────────────
if [[ "$DEV" =~ (nvme|mmcblk) ]]; then PART="${DEV}p"; else PART="$DEV"; fi

echo "Partitioning $DEV..."
sudo wipefs -af "$DEV" > /dev/null
sudo parted -s "$DEV" mklabel gpt

if $UEFI; then
  sudo parted -s "$DEV" mkpart ESP  fat32  1MiB    1025MiB
  sudo parted -s "$DEV" mkpart root ext4   1025MiB 100%
  sudo parted -s "$DEV" set 1 esp on
  sudo mkfs.fat  -F 32 -n NIXBOOT "${PART}1" > /dev/null
  sudo mkfs.ext4 -F    -L nixos   "${PART}2" > /dev/null
  sudo mount /dev/disk/by-label/nixos   /mnt
  sudo mkdir -p /mnt/boot
  sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot
else
  sudo parted -s "$DEV" mkpart bios_boot 1MiB  2MiB
  sudo parted -s "$DEV" mkpart root ext4 2MiB  100%
  sudo parted -s "$DEV" set 1 bios_grub on
  sudo mkfs.ext4 -F -L nixos "${PART}2" > /dev/null
  sudo mount /dev/disk/by-label/nixos /mnt
fi

# ── 5. Temporary swap (for the installer only) ────────────────────────────────
sudo fallocate -l 4G /mnt/.swapfile-install
sudo chmod 600       /mnt/.swapfile-install
sudo mkswap          /mnt/.swapfile-install > /dev/null
sudo swapon          /mnt/.swapfile-install

# ── 6. Generate hardware configuration ───────────────────────────────────────
echo "Detecting hardware..."
sudo nixos-generate-config --root /mnt --show-hardware-config > hardware-configuration.nix

# ── 7. Generate bootloader configuration ──────────────────────────────────────
if $UEFI; then
  cat > bootloader.nix << 'NIXEOF'
{ pkgs, lib, ... }: {
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable    = true;
    pkiBundle = "/var/lib/sbctl";
  };

  system.activationScripts.sbctl-keys = {
    text = ''
      if [ ! -d /var/lib/sbctl ]; then
        ${pkgs.sbctl}/bin/sbctl create-keys
      fi
    '';
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
NIXEOF
else
  cat > bootloader.nix << NIXEOF
{ ... }: {
  boot.loader.grub = {
    enable = true;
    device = "$DEV";
  };
}
NIXEOF
fi

git add -f hardware-configuration.nix bootloader.nix

# ── 8. Install ────────────────────────────────────────────────────────────────
echo "Installing NixOS..."
sudo nixos-install \
  --root /mnt \
  --flake ".#$FLAKE_ATTR" \
  --no-root-passwd \
  --option substituters "https://cache.nixos.org https://attic.xuyh0120.win/lantian https://cache.garnix.io" \
  --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc= cache.garnix.io:CTfPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="

# ── 9. Persist config on installed system ────────────────────────────────────
sudo cp -rT "$WORK_DIR" /mnt/etc/nixos

echo "Done! Rebooting..."
sudo reboot
