#!/usr/bin/env bash
set -euo pipefail

FLAKE_ATTR="nixos"

# ── 1. Prepare Workspace ──────────────────────────────────────────────────────
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# ── 2. Disk Selection ─────────────────────────────────────────────────────────
echo "--------------------------------------------------------------------------------"
echo "Detected the following physical disks:"
echo

# Find the block device backing the live ISO mount (to exclude it)
ISO_SOURCE=$(findmnt -n -o SOURCE /iso 2>/dev/null || true)
ISO_DISK=""
if [[ -n "$ISO_SOURCE" ]]; then
  ISO_DISK=$(lsblk -no PKNAME "$ISO_SOURCE" 2>/dev/null \
          || lsblk -dno NAME  "$ISO_SOURCE" 2>/dev/null \
          || true)
fi

# Enumerate all physical disks, excluding loop devices (-e 7) and the ISO disk
mapfile -t DISK_NAMES < <(
  lsblk -dn -o NAME,TYPE -e 7 \
    | awk '$2=="disk"{print $1}' \
    | grep -v "^${ISO_DISK}$" \
    || true
)

if [[ ${#DISK_NAMES[@]} -eq 0 ]]; then
  echo "ERROR: No eligible disks found." >&2
  exit 1
fi

i=0
for name in "${DISK_NAMES[@]}"; do
  SIZE=$(lsblk  -dno SIZE  "/dev/$name")
  MODEL=$(lsblk -dno MODEL "/dev/$name")
  echo "[$i] /dev/$name  ($SIZE)  $MODEL"
  i=$((i + 1))
done

echo
exec < /dev/tty
read -rp "Which device do you wish to install on? (Enter number): " CHOICE

if [[ -z "${DISK_NAMES[$CHOICE]+x}" ]]; then
  echo "Invalid choice." >&2
  exit 1
fi

DEV="/dev/${DISK_NAMES[$CHOICE]}"
echo "Selected: $DEV"
read -rp "DANGER: This will WIPE $DEV. Are you sure? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

# ── 3. Write device.nix ───────────────────────────────────────────────────────
# Both disko-config.nix and configuration.nix import this file.
echo "\"$DEV\"" > device.nix

# ── 4. Disk Setup ─────────────────────────────────────────────────────────────
echo "Running Disko..."
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix

# ── 5. Temporary Swap (for the installer process only) ────────────────────────
echo "Setting up temporary swap..."
sudo fallocate -l 4G /mnt/swapfile
sudo chmod 600 /mnt/swapfile
sudo mkswap  /mnt/swapfile
sudo swapon  /mnt/swapfile

# ── 6. Install ────────────────────────────────────────────────────────────────
echo "Starting installation..."
sudo nixos-install --root /mnt --flake ".#$FLAKE_ATTR" --no-root-passwd

echo "Installation complete. Rebooting..."
sudo reboot
