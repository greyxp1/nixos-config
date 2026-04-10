#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/greyxp1/nixos-config.git"
FLAKE_ATTR="nixos"
WORK_DIR="/tmp/nixos-config"

# ── 1. Clone config ───────────────────────────────────────────────────────────
rm -rf "$WORK_DIR"
git clone "$REPO" "$WORK_DIR"
cd "$WORK_DIR"

# ── 2. Disk selection ─────────────────────────────────────────────────────────
echo "--------------------------------------------------------------------------------"
echo "Available disks:"
echo

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

for i in "${!DISK_NAMES[@]}"; do
  printf "[%d] /dev/%s  %s  %s\n" "$i" \
    "${DISK_NAMES[$i]}" \
    "$(lsblk -dno SIZE  "/dev/${DISK_NAMES[$i]}")" \
    "$(lsblk -dno MODEL "/dev/${DISK_NAMES[$i]}")"
done
echo

exec < /dev/tty
read -rp "Install to disk (number): " CHOICE
[[ -z "${DISK_NAMES[$CHOICE]+x}" ]] && { echo "Invalid choice."; exit 1; }

DEV="/dev/${DISK_NAMES[$CHOICE]}"
echo "Selected: $DEV"
read -rp "DANGER: This will WIPE $DEV. Are you sure? (y/n): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

# ── 3. Detect firmware ────────────────────────────────────────────────────────
if [[ -d /sys/firmware/efi/efivars ]]; then UEFI=true; else UEFI=false; fi
echo "Firmware: $( $UEFI && echo UEFI || echo BIOS/Legacy )"

# ── 4. Partition and format ───────────────────────────────────────────────────
# NVMe and MMC devices use a 'p' separator before the partition number.
if [[ "$DEV" =~ (nvme|mmcblk) ]]; then PART="${DEV}p"; else PART="$DEV"; fi

echo "Wiping and partitioning $DEV..."
wipefs -af "$DEV"
parted -s "$DEV" mklabel gpt

if $UEFI; then
  parted -s "$DEV" mkpart ESP  fat32  1MiB    1025MiB
  parted -s "$DEV" mkpart root ext4   1025MiB 100%
  parted -s "$DEV" set 1 esp on
  mkfs.fat  -F 32 -n NIXBOOT "${PART}1"
  mkfs.ext4 -F    -L nixos   "${PART}2"
  mount /dev/disk/by-label/nixos   /mnt
  mkdir -p /mnt/boot
  mount /dev/disk/by-label/NIXBOOT /mnt/boot
else
  # GPT + BIOS-boot partition: GRUB writes its core image here.
  parted -s "$DEV" mkpart bios_boot 1MiB  2MiB
  parted -s "$DEV" mkpart root ext4 2MiB  100%
  parted -s "$DEV" set 1 bios_grub on
  mkfs.ext4 -F -L nixos "${PART}2"
  mount /dev/disk/by-label/nixos /mnt
fi

# ── 5. Temporary swap (for the installer only) ────────────────────────────────
fallocate -l 4G /mnt/.swapfile-install
chmod 600       /mnt/.swapfile-install
mkswap          /mnt/.swapfile-install
swapon          /mnt/.swapfile-install

# ── 6. Generate hardware configuration ───────────────────────────────────────
# nixos-generate-config inspects /mnt and writes every driver, UUID, and
# hardware detail the target machine needs — impossible to know ahead of time.
echo "Detecting hardware..."
nixos-generate-config --root /mnt --show-hardware-config > hardware-configuration.nix

# ── 7. Generate bootloader configuration ─────────────────────────────────────
# A small standalone NixOS module. Not committed to GitHub — it lives only in
# /etc/nixos on each installed machine alongside hardware-configuration.nix.
if $UEFI; then
  cat > bootloader.nix << 'NIXEOF'
{ ... }: {
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint     = "/boot";
}
NIXEOF
else
  cat > bootloader.nix << NIXEOF
{ ... }: {
  boot.loader.grub = {
    enable     = true;
    device     = "$DEV";
    efiSupport = false;
  };
}
NIXEOF
fi

# Stage both files so the flake evaluator includes them when it copies the
# source tree to the Nix store (flakes only see git-tracked files).
git add -f hardware-configuration.nix bootloader.nix

# ── 8. Install ────────────────────────────────────────────────────────────────
echo "Installing NixOS..."
nixos-install --root /mnt --flake ".#$FLAKE_ATTR" --no-root-passwd

# ── 9. Persist config on installed system ────────────────────────────────────
# Copies the full repo (including machine-specific generated files) to
# /etc/nixos so `nixos-rebuild switch --flake /etc/nixos#nixos` works after
# first boot with no extra steps.
cp -rT "$WORK_DIR" /mnt/etc/nixos

echo "Installation complete! Rebooting..."
reboot
