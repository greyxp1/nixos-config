#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/greyxp1/nixos-config.git"
WORK_DIR="/tmp/nixos-config"
HOST=""

# ── Parse arguments ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      [[ -z "${2-}" ]] && { echo "ERROR: --host requires a value."; exit 1; }
      HOST="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: bash <(curl -sL https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh) --host <main-pc|vm|generic>"
      exit 0 ;;
    *)
      echo "ERROR: Unknown argument: $1"
      echo "Usage: install.sh --host <main-pc|vm|generic>"
      exit 1 ;;
  esac
done

if [[ -z "$HOST" ]]; then
  echo "ERROR: --host is required."
  echo
  echo "  main-pc  — full desktop, Nvidia, CachyOS kernel, Secure Boot"
  echo "  vm       — full desktop, QEMU/SPICE guest tools, standard kernel"
  echo "  generic  — full desktop, portable hardware config, standard kernel"
  echo
  echo "Example:"
  echo "  bash <(curl -sL https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh) --host vm"
  exit 1
fi

case "$HOST" in
  main-pc|vm|generic) ;;
  *)
    echo "ERROR: Unknown host '$HOST'. Choose: main-pc, vm, or generic."
    exit 1 ;;
esac

# ── Cleanup on exit ───────────────────────────────────────────────────────────
cleanup() {
  sudo swapoff /mnt/.swapfile-install 2>/dev/null || true
  sudo umount -R /mnt 2>/dev/null || true
}
trap cleanup EXIT

# ── 1. Clone config ───────────────────────────────────────────────────────────
echo "==> Fetching config ($HOST)..."
rm -rf "$WORK_DIR"
git clone -q "$REPO" "$WORK_DIR"
cd "$WORK_DIR"

# Ensure interactive prompts can read from the terminal even when piped.
exec < /dev/tty

# ── 2. Require UEFI ───────────────────────────────────────────────────────────
if [[ ! -d /sys/firmware/efi/efivars ]]; then
  echo "ERROR: All host configurations require UEFI firmware. BIOS/Legacy is not supported."
  exit 1
fi
echo "==> Firmware: UEFI"

# ── 3. Disk selection ─────────────────────────────────────────────────────────
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
  echo "==> Disk: $DEV  $(lsblk -dno SIZE "$DEV")  $(lsblk -dno MODEL "$DEV")"
  read -rp "DANGER: This will WIPE $DEV. Are you sure? (y/n): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
else
  echo "Available disks:"
  for i in "${!DISK_NAMES[@]}"; do
    printf "  [%d] /dev/%s  %s  %s\n" "$i" \
      "${DISK_NAMES[$i]}" \
      "$(lsblk -dno SIZE  "/dev/${DISK_NAMES[$i]}")" \
      "$(lsblk -dno MODEL "/dev/${DISK_NAMES[$i]}")"
  done
  read -rp "Install to disk (number): " CHOICE
  [[ -z "${DISK_NAMES[$CHOICE]+x}" ]] && { echo "ERROR: Invalid choice."; exit 1; }
  DEV="/dev/${DISK_NAMES[$CHOICE]}"
  read -rp "DANGER: This will WIPE $DEV. Are you sure? (y/n): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

# ── 4. Partition and format ───────────────────────────────────────────────────
if [[ "$DEV" =~ (nvme|mmcblk) ]]; then PART="${DEV}p"; else PART="$DEV"; fi

echo "==> Partitioning $DEV..."
sudo wipefs -af "$DEV" > /dev/null
sudo parted -s "$DEV" mklabel gpt
sudo parted -s "$DEV" mkpart ESP  fat32  1MiB    1025MiB
sudo parted -s "$DEV" mkpart root ext4   1025MiB 100%
sudo parted -s "$DEV" set 1 esp on
sudo partprobe "$DEV"
sleep 1

sudo mkfs.fat  -F 32 -n NIXBOOT "${PART}1" > /dev/null
sudo mkfs.ext4 -F    -L nixos   "${PART}2" > /dev/null
sudo mount /dev/disk/by-label/nixos   /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot

# ── 5. Temporary swap (installer only) ───────────────────────────────────────
sudo fallocate -l 4G /mnt/.swapfile-install
sudo chmod 600       /mnt/.swapfile-install
sudo mkswap          /mnt/.swapfile-install > /dev/null
sudo swapon          /mnt/.swapfile-install

# ── 6. Install ────────────────────────────────────────────────────────────────
echo "==> Installing NixOS ($HOST)..."
sudo nixos-install \
  --root /mnt \
  --flake ".#$HOST" \
  --no-root-passwd \
  --option substituters "https://cache.nixos.org https://attic.xuyh0120.win/lantian https://cache.garnix.io" \
  --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="

# ── 7. Persist config on installed system ─────────────────────────────────────
sudo cp -rT "$WORK_DIR" /mnt/etc/nixos

echo "==> Done! Rebooting..."
sudo reboot
